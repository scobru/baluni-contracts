// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import './interfaces/IBaluniV1Rebalancer.sol';
import './interfaces/IBaluniV1Router.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

contract BaluniV1Pool is ERC20, ReentrancyGuard {
  IBaluniV1Rebalancer public rebalancer;
  address[] public assets;
  uint256[] public weights;
  uint256 public trigger;
  uint256 public ONE;
  address public router;
  uint256 public constant SWAP_FEE_BPS = 30;

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
    uint256 _trigger
  ) ERC20('Baluni LP', 'BALUNI-LP') {
    router = msg.sender;
    rebalancer = IBaluniV1Rebalancer(_rebalancer);
    assets = _assets;
    weights = _weights;
    ONE = 1e18;

    for (uint i = 0; i < assets.length; i++) {
      require(assets[i] != address(0), 'Invalid asset address');
      require(_weights[i] > 0, 'Invalid weight');
      IERC20 asset = IERC20(assets[i]);
      if (asset.allowance(address(this), address(rebalancer)) == 0) {
        asset.approve(address(rebalancer), type(uint256).max);
      }
    }

    trigger = _trigger;
  }

  modifier onlyRouter() {
    require(msg.sender == router, 'Only Factory');
    _;
  }

  function rebalanceWeights(address receiver) external {
    (uint256 totalValuation, uint256[] memory valuations) = _computeValuations();

    uint256[] memory amountsToAdd = _calculateAmountsToAdd(totalValuation, valuations);

    uint256 totalAddedLiquidity = _calculateTotalAddedLiquidity(amountsToAdd);

    _mint(receiver, totalAddedLiquidity);
    emit WeightsRebalanced(msg.sender, amountsToAdd);
  }

  function swap(address fromToken, address toToken, uint256 amount) external nonReentrant returns (uint256) {
    require(fromToken != toToken, 'Cannot swap the same token');
    require(amount > 0, 'Amount must be greater than zero');
    IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
    uint256 fee = (amount * SWAP_FEE_BPS) / 10000;
    uint256 amountAfterFee = amount - fee;
    uint256 receivedAmount = getAmountOut(fromToken, toToken, amountAfterFee);
    require(IERC20(toToken).balanceOf(address(this)) >= receivedAmount, 'Insufficient Liquidity');
    IERC20(toToken).transfer(msg.sender, receivedAmount);
    emit Swap(msg.sender, fromToken, toToken, amount, receivedAmount);

    return receivedAmount;
  }

  function mint(address to) external onlyRouter returns (uint256) {
    uint256 totalSupply = totalSupply();
    uint256 totalValue = 0;

    uint256[] memory reserves = getReserves();

    for (uint256 i = 0; i < assets.length; i++) {
      address asset = assets[i];
      uint256 actualBalance = IERC20(asset).balanceOf(address(this));
      uint256 amount = actualBalance - reserves[i];
      uint256 valuation = _convertTokenToNative(asset, amount);
      totalValue += valuation;
    }

    uint256 toMint;

    if (totalSupply == 0) {
      toMint = totalValue;
    } else {
      (uint256 totalLiquidity, ) = _computeTotalValuation();
      toMint = ((totalValue) * totalSupply) / totalLiquidity;
    }
    require(toMint != 0, 'Mint qty is 0');
    uint256 b4 = balanceOf(msg.sender);

    _mint(msg.sender, toMint);

    uint256 b = balanceOf(msg.sender) - b4;
    require(b == toMint, 'Mint Failed');

    emit Mint(to, toMint);

    return toMint;
  }

  function burn(address to) external {
    uint256 share = balanceOf(address(this));

    require(share > 0, 'Share must be greater than 0');
    uint256 totalSupply = totalSupply();

    require(totalSupply > 0, 'No liquidity');
    uint256[] memory amounts = new uint256[](assets.length);

    uint256 fee = (share * SWAP_FEE_BPS) / 10000;
    uint256 shareAfterFee = share - fee;

    for (uint256 i = 0; i < assets.length; i++) {
      uint256 assetBalance = IERC20(assets[i]).balanceOf(address(this));
      amounts[i] = (assetBalance * shareAfterFee) / totalSupply;
    }

    _burn(address(this), shareAfterFee);

    bool feeTransferSuccess = transfer(rebalancer.getTreasury(), fee);
    require(feeTransferSuccess, 'Fee transfer failed');

    for (uint256 i = 0; i < assets.length; i++) {
      bool assetTransferSuccess = IERC20(assets[i]).transfer(to, amounts[i]);
      require(assetTransferSuccess, 'Asset transfer failed');
    }

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

    uint256 adjustedAmount = amountAfterFee;
    if (fromDecimal != toDecimal) {
      uint256 factor;
      if (fromDecimal > toDecimal) {
        factor = 10 ** (fromDecimal - toDecimal);
        adjustedAmount /= factor;
      } else {
        factor = 10 ** (toDecimal - fromDecimal);
        adjustedAmount *= factor;
      }
    }

    uint256 amountOut = (adjustedAmount * rate) / (10 ** toDecimal);
    return amountOut;
  }

  function performRebalanceIfNeeded(address _sender) external {
    uint256 requiredBalance = (totalSupply() * 1000) / 10000;
    require(balanceOf(_sender) >= requiredBalance, 'Under 5% LP share');
    _performRebalanceIfNeeded();
  }

  function getDeviation() external view returns (bool[] memory directions, uint256[] memory deviations) {
    (uint256 totalUsdValuation, uint256[] memory usdValuations) = _computeTotalValuation();
    uint256 numAssets = assets.length;

    directions = new bool[](numAssets);
    deviations = new uint256[](numAssets);

    for (uint256 i = 0; i < numAssets; i++) {
      uint256 currentWeight = (usdValuations[i] * 10000) / totalUsdValuation;
      uint256 targetWeight = weights[i];

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
    uint256[] memory reserves = new uint256[](assets.length);
    for (uint256 i = 0; i < assets.length; i++) {
      reserves[i] = IERC20(assets[i]).balanceOf(address(this));
    }
    return reserves;
  }

  function getAssets() external view returns (address[] memory) {
    return assets;
  }

  function getWeights() external view returns (uint256[] memory) {
    return weights;
  }

  function changeRebalancer(address _newRebalancer) external onlyRouter {
    rebalancer = IBaluniV1Rebalancer(_newRebalancer);
  }

  function changeRouter(address _newRouter) external onlyRouter {
    router = _newRouter;
  }

  function _computeTotalValuation() internal view returns (uint256 totalValuation, uint256[] memory valuations) {
    uint256 numAssets = assets.length;
    valuations = new uint256[](numAssets);
    for (uint256 i = 0; i < numAssets; i++) {
      IERC20 asset = IERC20(assets[i]);
      uint256 valuation = _convertTokenToNative(address(asset), asset.balanceOf(address(this)));
      valuations[i] = valuation;
      totalValuation += valuations[i];
    }
    return (totalValuation, valuations);
  }

  function _performRebalanceIfNeeded() internal {
    rebalancer.rebalance(assets, weights, address(this), address(this), trigger);
    emit RebalancePerformed(msg.sender, assets);
  }

  function _calculateTotalAddedLiquidity(uint256[] memory amountsToAdd) internal returns (uint256 totalAddedLiquidity) {
    for (uint256 i = 0; i < assets.length; i++) {
      if (amountsToAdd[i] > 0) {
        _transferAndCalculateLiquidity(i, amountsToAdd[i]);
        totalAddedLiquidity += amountsToAdd[i];
      }
    }
    return totalAddedLiquidity;
  }

  function _computeValuations() internal view returns (uint256 totalValuation, uint256[] memory valuations) {
    valuations = new uint256[](assets.length);
    for (uint256 i = 0; i < assets.length; i++) {
      valuations[i] = _convertTokenToNative(assets[i], IERC20(assets[i]).balanceOf(address(this)));
      totalValuation += valuations[i];
    }
    return (totalValuation, valuations);
  }

  function _calculateAmountsToAdd(
    uint256 totalValuation,
    uint256[] memory valuations
  ) internal view returns (uint256[] memory amountsToAdd) {
    amountsToAdd = new uint256[](assets.length);
    for (uint256 i = 0; i < assets.length; i++) {
      amountsToAdd[i] = _calculateSingleAmountToAdd(totalValuation, valuations[i], weights[i]);
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
    IERC20(assets[index]).transferFrom(msg.sender, address(this), _convertNativeToToken(assets[index], amountToAdd));
  }

  function _convertNativeToToken(address fromToken, uint256 amount) internal view returns (uint256) {
    uint256 rate;
    address WNATIVE = rebalancer.getWNATIVEAddress();
    uint8 tokenDecimal = IERC20Metadata(fromToken).decimals();
    uint8 wnativeDecimal = IERC20Metadata(WNATIVE).decimals();

    try rebalancer.getRateToEth(IERC20(fromToken), false) returns (uint256 _rate) {
      rate = _rate;
    } catch {
      return 0;
    }

    uint256 factor;
    if (tokenDecimal != wnativeDecimal) {
      factor = 10 ** uint256(max(tokenDecimal, wnativeDecimal) - min(tokenDecimal, wnativeDecimal));
      if (tokenDecimal > wnativeDecimal) {
        amount *= factor;
      } else {
        amount /= factor;
      }
    }

    uint256 tokenAmount = (amount * ONE) / rate;

    // Adjust the final result to the token's decimals
    if (tokenDecimal != wnativeDecimal) {
      if (wnativeDecimal > tokenDecimal) {
        tokenAmount /= factor;
      } else {
        tokenAmount *= factor;
      }
    }

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
        amount *= factor;
      } else {
        amount *= factor;
      }
    } else if (fromDecimal != 18) {
      factor = 10 ** (18 - fromDecimal);
      amount *= factor;
    }

    return (amount * rate) / ONE;
  }
}
