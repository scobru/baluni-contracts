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

  /**
   * @dev Initializes the assets and their weights for the pool.
   * @param _assets The array of asset addresses.
   * @param _weights The array of weights corresponding to each asset.
   */
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

  /**
   * @dev Rebalances the weights of the pool by calculating the amounts to add for each token,
   * transferring the calculated amounts from the user to the pool, minting the total added liquidity,
   * updating the reserves, and emitting an event to indicate the rebalancing of weights.
   * @param receiver The address to receive the minted liquidity tokens.
   */
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

  /**
   * @dev Swaps `amount` of `fromToken` to `toToken` and transfers the received amount to `receiver`.
   *
   * Requirements:
   * - `fromToken` and `toToken` must be different tokens.
   * - `amount` must be greater than zero.
   * - Sufficient liquidity of `toToken` must be available in the contract.
   *
   * Emits a `Swap` event with the details of the swap.
   *
   * Updates the reserves after the swap.
   *
   * @param fromToken The address of the token to swap from.
   * @param toToken The address of the token to swap to.
   * @param amount The amount of `fromToken` to swap.
   * @param receiver The address to receive the swapped tokens.
   * @return The amount of `toToken` received after the swap.
   */
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

  /**
   * @dev Mints new tokens and adds them to the specified address.
   * @param to The address to which the new tokens will be minted.
   * @return The amount of tokens minted.
   */
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

  /**
   * @dev Burns the pool tokens and transfers the underlying assets to the specified address.
   * @param to The address to transfer the underlying assets to.
   * @notice This function can only be called by the periphery contract.
   * @notice The pool tokens must have a balance greater than 0.
   * @notice The total supply of pool tokens must be greater than 0.
   * @notice The function calculates the amounts of each underlying asset to transfer based on the share of pool tokens being burned.
   * @notice A fee is deducted from the share of pool tokens being burned and transferred to the treasury address.
   * @notice The function checks if the pool has sufficient liquidity before performing any transfers.
   * @notice If any transfer fails, the function reverts the entire operation.
   * @notice After the transfers, the function updates the reserves of the pool.
   * @notice Emits a `Burn` event with the address and share of pool tokens burned.
   */
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

  /**
   * @dev Calculates the amount of `toToken` that will be received when swapping `fromToken` for `toToken`.
   * @param fromToken The address of the token being swapped from.
   * @param toToken The address of the token being swapped to.
   * @param amount The amount of `fromToken` being swapped.
   * @return The amount of `toToken` that will be received.
   */
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

  /**
   * @dev Performs rebalance if needed based on the LP share of the sender.
   * @param _sender The address of the sender.
   */
  function performRebalanceIfNeeded(address _sender) external {
    uint256 requiredBalance = (totalSupply() * 1000) / 10000;
    require(balanceOf(_sender) >= requiredBalance, 'Under 5% LP share');
    _performRebalanceIfNeeded();
    _updateReserves();
  }

  /**
   * @dev Returns the deviation between the current weights and target weights of the assets in the pool.
   * @return directions An array of boolean values indicating whether the current weight is higher (true) or lower (false) than the target weight.
   */
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

  /**
   * @dev Returns the liquidity of a specific asset in the pool.
   * @param assetIndex The index of the asset.
   * @return The liquidity of the asset.
   */
  function assetLiquidity(uint256 assetIndex) external view returns (uint256) {
    (, uint256[] memory usdValuations) = _computeTotalValuation();
    require(assetIndex < usdValuations.length, 'Invalid asset index');
    return usdValuations[assetIndex];
  }

  /**
   * @dev Returns the total liquidity of the pool.
   * @return The total liquidity of the pool.
   */
  function liquidity() external view returns (uint256) {
    (uint256 totalVal, ) = _computeTotalValuation();
    return totalVal;
  }

  /**
   * @dev Returns the unit price of the pool.
   * @return The unit price of the pool.
   */
  function unitPrice() external view returns (uint256) {
    (uint256 totalVal, ) = _computeTotalValuation();
    uint256 totalSupply = totalSupply();
    if (totalSupply == 0) {
      return 0;
    }
    return (totalVal * ONE) / totalSupply;
  }

  /**
   * @dev Returns an array of reserves for each asset in the pool.
   * @return An array of reserves.
   */
  function getReserves() public view returns (uint256[] memory) {
    uint256[] memory _reserves = new uint256[](assetInfos.length);
    for (uint256 i = 0; i < assetInfos.length; i++) {
      _reserves[i] = reserves[assetInfos[i].asset];
    }
    return _reserves;
  }

  /**
   * @dev Retrieves the list of assets in the pool.
   * @return An array of addresses representing the assets.
   */
  function getAssets() external view returns (address[] memory) {
    address[] memory assets = new address[](assetInfos.length);
    for (uint256 i = 0; i < assetInfos.length; i++) {
      assets[i] = assetInfos[i].asset;
    }
    return assets;
  }

  /**
   * @dev Retrieves the list of weights associated with the assets in the pool.
   * @return An array of uint256 values representing the weights.
   */
  function getWeights() external view returns (uint256[] memory) {
    uint256[] memory weights = new uint256[](assetInfos.length);
    for (uint256 i = 0; i < assetInfos.length; i++) {
      weights[i] = assetInfos[i].weight;
    }
    return weights;
  }

  /**
   * @dev Computes the total valuation of the assets in the pool.
   * @return totalValuation The total valuation of the assets.
   * @return valuations An array of valuations for each asset in the pool.
   */
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

  /**
   * @dev Performs rebalance if needed.
   * This function retrieves the assets and weights from the `assetInfos` array,
   * and calls the `rebalance` function of the `rebalancer` contract with the retrieved values.
   * It emits a `RebalancePerformed` event after the rebalance is performed.
   * @notice This function should only be called internally.
   */
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

  /**
   * @dev Calculates the total added liquidity based on the amounts to add.
   * @param amountsToAdd An array of amounts to add for each asset.
   * @return totalAddedLiquidity The total added liquidity.
   */
  function _calculateTotalAddedLiquidity(
    uint256[] memory amountsToAdd
  ) internal view returns (uint256 totalAddedLiquidity) {
    for (uint256 i = 0; i < assetInfos.length; i++) {
      totalAddedLiquidity += amountsToAdd[i];
    }
    return totalAddedLiquidity;
  }

  /**
   * @dev Computes the valuations of assets held in the contract.
   * @return totalValuation The total valuation of all assets.
   * @return valuations An array containing the valuations of each asset.
   */
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

  /**
   * @dev Calculates the amounts to add to each asset based on the total valuation and individual valuations.
   * @param totalValuation The total valuation of the assets.
   * @param valuations An array of individual valuations for each asset.
   * @return amountsToAdd An array of amounts to add to each asset.
   */
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

  /**
   * @dev Internal function to transfer tokens from the caller to the contract and calculate the liquidity.
   * @param index The index of the asset in the assetInfos array.
   * @param amountToAdd The amount of native tokens to add as liquidity.
   */
  function _transferAndCalculateLiquidity(uint256 index, uint256 amountToAdd) internal {
    uint256 tokenAmount = _convertNativeToToken(assetInfos[index].asset, amountToAdd);
    require(tokenAmount > 0, 'Invalid token amount to add');
    IERC20(assetInfos[index].asset).transferFrom(msg.sender, address(this), tokenAmount);
    reserves[assetInfos[index].asset] += tokenAmount;
  }

  /**
   * @dev Converts the specified amount of native token to the corresponding token amount.
   * @param fromToken The address of the native token to convert from.
   * @param amount The amount of native token to convert.
   * @return The corresponding token amount.
   */
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

  /**
   * @dev Returns the maximum of two uint8 values.
   * @param a The first uint8 value.
   * @param b The second uint8 value.
   * @return The maximum value between a and b.
   */
  function max(uint8 a, uint8 b) private pure returns (uint8) {
    return a >= b ? a : b;
  }

  /**
   * @dev Returns the minimum of two uint8 values.
   * @param a The first uint8 value.
   * @param b The second uint8 value.
   * @return The minimum value between a and b.
   */
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

  /**
   * @dev Updates the reserves of all assets in the pool.
   */
  function _updateReserves() internal {
    for (uint256 i = 0; i < assetInfos.length; i++) {
      address asset = assetInfos[i].asset;
      uint256 newReserve = IERC20(asset).balanceOf(address(this));
      reserves[asset] = newReserve;
    }
  }
}
