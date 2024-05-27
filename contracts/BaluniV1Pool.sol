// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import './interfaces/IBaluniV1Rebalancer.sol';
import './interfaces/IBaluniV1Router.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

contract BaluniV1Pool is ERC20, ReentrancyGuard {
  IBaluniV1Rebalancer public rebalancer;
  AssetInfo[] public assetInfos;
  uint256 public trigger;
  uint256 public ONE;
  address public periphery;
  uint256 public constant SWAP_FEE_BPS = 30;

  mapping(address => uint256) public reserves;

  struct AssetInfo {
    address asset;
    uint256 weight;
  }

  event RebalancePerformed(address indexed by, address[] assets);
  event WeightsRebalanced(address indexed user, uint256[] amountsAdded);
  event Burn(address indexed user, uint256 sharesBurned);
  event Mint(address indexed to, uint256 sharesMinted);
  event Swap(
    address indexed user,
    address indexed fromToken,
    address indexed toToken,
    uint256 amountIn,
    uint256 amountOut
  );

  constructor(
    address _rebalancer,
    address[] memory _assets,
    uint256[] memory _weights,
    uint256 _trigger,
    address _periphery
  ) ERC20('Baluni LP', 'BALUNI-LP') {
    periphery = _periphery;
    rebalancer = IBaluniV1Rebalancer(_rebalancer);
    ONE = 1e18;

    initializeAssets(_assets, _weights);
    _updateReserves();

    trigger = _trigger;
  }

  modifier onlyPeriphery() {
    require(msg.sender == periphery, 'Only Periphery');
    _;
  }

  function initializeAssets(address[] memory _assets, uint256[] memory _weights) internal {
    require(_assets.length == _weights.length, 'Assets and weights length mismatch');

    for (uint256 i = 0; i < _assets.length; i++) {
      require(_assets[i] != address(0), 'Invalid asset address');
      require(_weights[i] > 0, 'Invalid weight');

      assetInfos.push(AssetInfo({asset: _assets[i], weight: _weights[i]}));

      IERC20 asset = IERC20(_assets[i]);
      if (asset.allowance(address(this), address(rebalancer)) == 0) {
        asset.approve(address(rebalancer), type(uint256).max);
      }
    }
  }

  function rebalanceWeights(address receiver) external {
    (uint256 totalValuation, uint256[] memory valuations) = _computeValuations();

    uint256[] memory amountsToAdd = _calculateAmountsToAdd(totalValuation, valuations);

    // Calculate total added liquidity before minting
    uint256 totalAddedLiquidity = _calculateTotalAddedLiquidity(amountsToAdd);

    // Transfer the calculated amounts from the user to the pool
    for (uint256 i = 0; i < amountsToAdd.length; i++) {
      if (amountsToAdd[i] > 0) {
        _transferAndCalculateLiquidity(i, amountsToAdd[i]);
      }
    }

    _mint(receiver, totalAddedLiquidity);

    _updateReserves();

    emit WeightsRebalanced(msg.sender, amountsToAdd);
  }

  function swap(
    address fromToken,
    address toToken,
    uint256 amount,
    address receiver
  ) external nonReentrant returns (uint256) {
    require(fromToken != toToken, 'Cannot swap the same token');
    require(amount > 0, 'Amount must be greater than zero');
    IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
    uint256 receivedAmount = getAmountOut(fromToken, toToken, amount);
    require(IERC20(toToken).balanceOf(address(this)) >= receivedAmount, 'Insufficient Liquidity');
    IERC20(toToken).transfer(receiver, receivedAmount);
    emit Swap(receiver, fromToken, toToken, amount, receivedAmount);

    _updateReserves();

    return receivedAmount;
  }

  function mint(address to) external onlyPeriphery returns (uint256) {
    uint256 totalSupply = totalSupply();
    uint256 totalValue = 0;

    uint256[] memory _reserves = getReserves();

    require(assetInfos.length == _reserves.length, 'Invalid reserves length');
    require(assetInfos.length > 0, 'No assets');

    for (uint256 i = 0; i < assetInfos.length; i++) {
      address asset = assetInfos[i].asset;
      uint256 actualBalance = IERC20(asset).balanceOf(address(this));
      require(actualBalance > 0, 'Balance must be greater than 0');
      uint256 amount = actualBalance - _reserves[i];
      require(amount > 0, 'Amount must be greater than 0');
      uint256 valuation = _convertTokenToNative(asset, amount);
      totalValue += valuation;
    }

    require(totalValue > 0, 'Total value must be greater than 0');

    uint256 toMint;

    if (totalSupply == 0) {
      toMint = totalValue;
    } else {
      (uint256 totalLiquidity, ) = _computeTotalValuation();
      toMint = ((totalValue) * totalSupply) / totalLiquidity;
    }
    require(toMint != 0, 'Mint qty is 0');
    uint256 b4 = balanceOf(msg.sender);

    _mint(to, toMint);

    uint256 b = balanceOf(to) - b4;
    require(b == toMint, 'Mint Failed');

    _updateReserves();

    emit Mint(to, toMint);

    return toMint;
  }

  function burn(address to) external onlyPeriphery {
    uint256 share = balanceOf(address(this));

    require(share > 0, 'Share must be greater than 0');
    uint256 totalSupply = totalSupply();

    require(totalSupply > 0, 'No liquidity');
    uint256[] memory amounts = new uint256[](assetInfos.length);

    uint256 fee = (share * SWAP_FEE_BPS) / 10000;
    uint256 shareAfterFee = share - fee;

    for (uint256 i = 0; i < assetInfos.length; i++) {
      uint256 assetBalance = IERC20(assetInfos[i].asset).balanceOf(address(this));
      amounts[i] = (assetBalance * shareAfterFee) / totalSupply;
    }

    require(balanceOf(address(this)) >= shareAfterFee, 'Insufficient liquidity');

    bool feeTransferSuccess = IERC20(address(this)).transfer(rebalancer.getTreasury(), fee);
    require(feeTransferSuccess, 'Fee transfer failed');

    require(balanceOf(address(this)) >= shareAfterFee, 'Insufficient liquidity');
    _burn(address(this), shareAfterFee);

    for (uint256 i = 0; i < assetInfos.length; i++) {
      require(IERC20(assetInfos[i].asset).balanceOf(address(this)) >= amounts[i], 'Insufficient Liquidity');
      bool assetTransferSuccess = IERC20(assetInfos[i].asset).transfer(to, amounts[i]);
      require(assetTransferSuccess, 'Asset transfer failed');
    }

    _updateReserves();

    emit Burn(to, shareAfterFee);
  }

  function getAmountOut(address fromToken, address toToken, uint256 amount) public view returns (uint256) {
    require(fromToken != toToken, 'Cannot swap the same token');
    require(amount > 0, 'Amount must be greater than zero');

    uint256 fee = (amount * SWAP_FEE_BPS) / 10000;
    uint256 amountAfterFee = amount - fee;

    uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
    uint8 toDecimal = IERC20Metadata(toToken).decimals();

    uint256 rate;

    try rebalancer.getRate(IERC20(fromToken), IERC20(toToken), false) returns (uint256 _rate) {
      rate = _rate;
    } catch {
      return 0;
    }

    uint256 factor;
    uint256 numerator = 10 ** fromDecimal;
    uint256 denominator = 10 ** toDecimal;

    rate = (rate * numerator) / denominator;

    uint256 adjustedAmount = amountAfterFee;
    uint256 amountOut;

    if (fromDecimal != toDecimal) {
      if (fromDecimal > toDecimal) {
        factor = 10 ** (fromDecimal - toDecimal);
        adjustedAmount /= factor;
        amountOut = (adjustedAmount * rate) / 10 ** toDecimal;
      } else {
        factor = 10 ** (toDecimal - fromDecimal);
        adjustedAmount *= factor;
        amountOut = (adjustedAmount * rate) / (10 ** toDecimal);
      }
    } else {
      amountOut = (adjustedAmount * rate) / 1e18;
    }

    return amountOut;
  }

  function performRebalanceIfNeeded(address _sender) external {
    uint256 requiredBalance = (totalSupply() * 1000) / 10000;
    require(balanceOf(_sender) >= requiredBalance, 'Under 5% LP share');
    _performRebalanceIfNeeded();
    _updateReserves();
  }

  function getDeviation() public view returns (bool[] memory directions, uint256[] memory deviations) {
    (uint256 totalUsdValuation, uint256[] memory usdValuations) = _computeTotalValuation();
    uint256 numAssets = assetInfos.length;

    directions = new bool[](numAssets);
    deviations = new uint256[](numAssets);

    for (uint256 i = 0; i < numAssets; i++) {
      uint256 currentWeight = (usdValuations[i] * 10000) / totalUsdValuation;
      uint256 targetWeight = assetInfos[i].weight;

      if (currentWeight > targetWeight) {
        deviations[i] = currentWeight - targetWeight;
        directions[i] = true;
      } else {
        deviations[i] = targetWeight - currentWeight;
        directions[i] = false;
      }
    }

    return (directions, deviations);
  }

  function assetLiquidity(uint256 assetIndex) external view returns (uint256) {
    (, uint256[] memory usdValuations) = _computeTotalValuation();
    require(assetIndex < usdValuations.length, 'Invalid asset index');
    return usdValuations[assetIndex];
  }

  function liquidity() external view returns (uint256) {
    (uint256 totalVal, ) = _computeTotalValuation();
    return totalVal;
  }

  function unitPrice() external view returns (uint256) {
    (uint256 totalVal, ) = _computeTotalValuation();
    uint256 totalSupply = totalSupply();
    if (totalSupply == 0) {
      return 0;
    }
    return (totalVal * ONE) / totalSupply;
  }

  function getReserves() public view returns (uint256[] memory) {
    uint256[] memory _reserves = new uint256[](assetInfos.length);
    for (uint256 i = 0; i < assetInfos.length; i++) {
      _reserves[i] = reserves[assetInfos[i].asset];
    }
    return _reserves;
  }

  function getAssets() external view returns (address[] memory) {
    address[] memory assets = new address[](assetInfos.length);
    for (uint256 i = 0; i < assetInfos.length; i++) {
      assets[i] = assetInfos[i].asset;
    }
    return assets;
  }

  function getWeights() external view returns (uint256[] memory) {
    uint256[] memory weights = new uint256[](assetInfos.length);
    for (uint256 i = 0; i < assetInfos.length; i++) {
      weights[i] = assetInfos[i].weight;
    }
    return weights;
  }

  function _computeTotalValuation() internal view returns (uint256 totalValuation, uint256[] memory valuations) {
    uint256 numAssets = assetInfos.length;
    valuations = new uint256[](numAssets);
    for (uint256 i = 0; i < numAssets; i++) {
      IERC20 asset = IERC20(assetInfos[i].asset);
      uint256 valuation = _convertTokenToNative(address(asset), reserves[assetInfos[i].asset]);
      valuations[i] = valuation;
      totalValuation += valuations[i];
    }
    return (totalValuation, valuations);
  }

  function _performRebalanceIfNeeded() internal {
    address[] memory assets = new address[](assetInfos.length);
    uint256[] memory weights = new uint256[](assetInfos.length);
    for (uint256 i = 0; i < assetInfos.length; i++) {
      assets[i] = assetInfos[i].asset;
      weights[i] = assetInfos[i].weight;
    }
    rebalancer.rebalance(assets, weights, address(this), address(this), trigger);
    emit RebalancePerformed(msg.sender, assets);
  }

  function _calculateTotalAddedLiquidity(
    uint256[] memory amountsToAdd
  ) internal view returns (uint256 totalAddedLiquidity) {
    for (uint256 i = 0; i < assetInfos.length; i++) {
      totalAddedLiquidity += amountsToAdd[i];
    }
    return totalAddedLiquidity;
  }

  function _computeValuations() internal view returns (uint256 totalValuation, uint256[] memory valuations) {
    valuations = new uint256[](assetInfos.length);
    for (uint256 i = 0; i < assetInfos.length; i++) {
      valuations[i] = _convertTokenToNative(assetInfos[i].asset, IERC20(assetInfos[i].asset).balanceOf(address(this)));
      totalValuation += valuations[i];
    }
    return (totalValuation, valuations);
  }

  // function _calculateAmountsToAdd(
  //   uint256 totalValuation,
  //   uint256[] memory valuations
  // ) internal view returns (uint256[] memory amountsToAdd) {
  //   amountsToAdd = new uint256[](assetInfos.length);
  //   for (uint256 i = 0; i < assetInfos.length; i++) {
  //     uint256 targetValuation = (totalValuation * assetInfos[i].weight) / 10000;
  //     if (valuations[i] < targetValuation) {
  //       amountsToAdd[i] = targetValuation - valuations[i];
  //     }
  //   }
  //   return amountsToAdd;
  // }

  function _calculateAmountsToAdd(
    uint256 totalValuation,
    uint256[] memory valuations
  ) internal view returns (uint256[] memory amountsToAdd) {
    amountsToAdd = new uint256[](assetInfos.length);
    for (uint256 i = 0; i < assetInfos.length; i++) {
      uint256 targetValuation = (totalValuation * assetInfos[i].weight) / 10000;
      if (valuations[i] < targetValuation) {
        amountsToAdd[i] = targetValuation - valuations[i];
      } else {
        amountsToAdd[i] = 0;
      }
    }
    return amountsToAdd;
  }

  function _calculateSingleAmountToAdd(
    uint256 totalValuation,
    uint256 valuation,
    uint256 weight
  ) internal pure returns (uint256 amountToAdd) {
    uint256 targetValuation = (totalValuation * weight) / 10000;
    if (valuation < targetValuation) {
      amountToAdd = targetValuation - valuation;
    }
    return amountToAdd;
  }

  function _transferAndCalculateLiquidity(uint256 index, uint256 amountToAdd) internal {
    uint256 tokenAmount = _convertNativeToToken(assetInfos[index].asset, amountToAdd);
    require(tokenAmount > 0, 'Invalid token amount to add');
    IERC20(assetInfos[index].asset).transferFrom(msg.sender, address(this), tokenAmount);
    reserves[assetInfos[index].asset] += tokenAmount;
  }

  function _convertNativeToToken(address fromToken, uint256 amount) internal view returns (uint256) {
    uint256 rate;

    address WNATIVE = rebalancer.getWNATIVEAddress();

    try rebalancer.getRate(IERC20(WNATIVE), IERC20(fromToken), false) returns (uint256 _rate) {
      rate = _rate;
    } catch {
      return 0;
    }
    uint256 tokenAmount = ((amount * rate) / ONE);

    return tokenAmount;
  }

  function max(uint8 a, uint8 b) private pure returns (uint8) {
    return a >= b ? a : b;
  }

  function min(uint8 a, uint8 b) private pure returns (uint8) {
    return a <= b ? a : b;
  }

  function _convertTokenToNative(address fromToken, uint256 amount) internal view returns (uint256 scaledAmount) {
    uint256 rate;
    address WNATIVE = rebalancer.getWNATIVEAddress();
    uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
    uint8 wnativeDecimal = IERC20Metadata(WNATIVE).decimals();

    try rebalancer.getRateToEth(IERC20(fromToken), false) returns (uint256 _rate) {
      rate = _rate;
    } catch {
      return 0;
    }

    uint256 factor;
    uint256 numerator = 10 ** fromDecimal;
    uint256 denominator = ONE;

    rate = (rate * numerator) / denominator;

    if (fromDecimal != wnativeDecimal) {
      factor = 10 ** uint256(max(fromDecimal, wnativeDecimal) - min(fromDecimal, wnativeDecimal));
      if (fromDecimal > wnativeDecimal) {
        amount /= factor;
      } else {
        amount *= factor;
      }
    } else if (fromDecimal != 18) {
      factor = 10 ** (18 - fromDecimal);
      amount *= factor;
    }

    return (amount * rate) / ONE;
  }

  function _updateReserves() internal {
    for (uint256 i = 0; i < assetInfos.length; i++) {
      address asset = assetInfos[i].asset;
      uint256 newReserve = IERC20(asset).balanceOf(address(this));
      reserves[asset] = newReserve;
    }
  }
}
