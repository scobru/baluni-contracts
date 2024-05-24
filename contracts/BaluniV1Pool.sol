// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;
/**
 *  __                  __                      __
 * /  |                /  |                    /  |
 * $$ |____    ______  $$ | __    __  _______  $$/
 * $$      \  /      \ $$ |/  |  /  |/       \ /  |
 * $$$$$$$  | $$$$$$  |$$ |$$ |  $$ |$$$$$$$  |$$ |
 * $$ |  $$ | /    $$ |$$ |$$ |  $$ |$$ |  $$ |$$ |
 * $$ |__$$ |/$$$$$$$ |$$ |$$ \__$$ |$$ |  $$ |$$ |
 * $$    $$/ $$    $$ |$$ |$$    $$/ $$ |  $$ |$$ |
 * $$$$$$$/   $$$$$$$/ $$/  $$$$$$/  $$/   $$/ $$/
 *
 *
 *                  ,-""""-.
 *                ,'      _ `.
 *               /       )_)  \
 *              :              :
 *              \              /
 *               \            /
 *                `.        ,'
 *                  `.    ,'
 *                    `.,'
 *                     /\`.   ,-._
 *                         `-'    \__
 *                              .
 *               s                \
 *                                \\
 *                                 \\
 *                                  >\/7
 *                              _.-(6'  \
 *                             (=___._/` \
 *                                  )  \ |
 *                                 /   / |
 *                                /    > /
 *                               j    < _\
 *                           _.-' :      ``.
 *                           \ r=._\        `.
 */

import './interfaces/IBaluniV1Rebalancer.sol';
import './interfaces/IBaluniV1Router.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

contract BaluniV1Pool is ERC20, ReentrancyGuard {
  IBaluniV1Rebalancer public rebalancer;

  address[] public assets;
  uint256[] public weights;

  uint256 public trigger;
  uint256 public ONE = 1e18;
  address public factory;

  uint256 public constant SWAP_FEE_BPS = 30;

  mapping(address => uint256) public balances;

  event RebalancePerformed(address indexed by, address[] assets);
  event LiquidityRemoved(address indexed user, uint256[] amounts, uint256 sharesBurned);

  /**
   * @dev Initializes the BaluniV1Pool contract.
   * @param _rebalancer The address of the rebalancer contract.
   * @param _assets The addresses of the asset contracts.
   * @param _weights The weights of the assets.
   * @param _trigger The trigger value.
   */
  constructor(
    address _rebalancer,
    address[] memory _assets,
    uint256[] memory _weights,
    uint256 _trigger
  ) ERC20('Baluni LP', 'BALUNI-LP') ReentrancyGuard() {
    // Initialize contract variables
    factory = msg.sender;
    rebalancer = IBaluniV1Rebalancer(_rebalancer);
    assets = _assets;
    weights = _weights;

    // Validate asset addresses and weights
    for (uint i = 0; i < assets.length; i++) {
      require(assets[i] != address(0), 'Invalid asset address');
      require(_weights[i] > 0, 'Invalid weight');
      IERC20 asset = IERC20(assets[i]);
      // Approve rebalancer to spend assets
      if (asset.allowance(address(this), address(rebalancer)) == 0) {
        asset.approve(address(rebalancer), type(uint256).max);
      }
    }

    // Set trigger value
    trigger = _trigger;
  }

  /**
   * @dev Calculates the received amount after applying a fee, based on the conversion rate between two tokens.
   * @param fromToken The address of the token being converted from.
   * @param toToken The address of the token being converted to.
   * @param amountAfterFee The amount to be converted after applying a fee.
   * @return receivedAmount The received amount after applying the conversion rate and fee.
   */
  function _convertTokenWithRate(
    address fromToken,
    address toToken,
    uint256 amountAfterFee
  ) internal view returns (uint256 receivedAmount) {
    uint256 rate = rebalancer.getRate(IERC20(fromToken), IERC20(toToken), false);

    uint8 fromDecimals = IERC20Metadata(fromToken).decimals();
    uint8 toDecimals = IERC20Metadata(toToken).decimals();

    uint256 adjustedAmount = amountAfterFee * rate;

    if (fromDecimals > toDecimals) {
      receivedAmount = (adjustedAmount * (10 ** (fromDecimals - toDecimals))) / ONE;
    } else if (toDecimals > fromDecimals) {
      receivedAmount = adjustedAmount / (10 ** (toDecimals - fromDecimals)) / ONE;
    } else {
      receivedAmount = adjustedAmount / ONE;
    }

    return receivedAmount;
  }

  /**
   * @dev Swaps tokens from one address to another.
   * @param fromToken The address of the token to swap from.
   * @param toToken The address of the token to swap to.
   * @param amount The amount of tokens to swap.
   * @return The amount of tokens received after the swap.
   */
  function swap(address fromToken, address toToken, uint256 amount) external nonReentrant returns (uint256) {
    require(fromToken != toToken, 'Cannot swap the same token');
    require(amount > 0, 'Amount must be greater than zero');
    IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
    uint256 fee = (amount * SWAP_FEE_BPS) / 10000;
    uint256 amountAfterFee = amount - fee;
    uint256 receivedAmount = _convertTokenWithRate(fromToken, toToken, amountAfterFee);
    require(IERC20(toToken).balanceOf(address(this)) >= receivedAmount, 'Insufficient Liquidity');
    IERC20(toToken).transfer(msg.sender, receivedAmount);
    emit Swap(msg.sender, fromToken, toToken, amount, receivedAmount);

    return receivedAmount;
  }

  /**
   * @dev Calculates the amount of `toToken` that will be received after swapping `fromToken` for `toToken`.
   * @param fromToken The address of the token being swapped from.
   * @param toToken The address of the token being swapped to.
   * @param amount The amount of `fromToken` being swapped.
   * @return The amount of `toToken` that will be received after the swap.
   * @notice This function is view-only and does not modify the contract state.
   * @notice The `fromToken` and `toToken` must be either `asset1` or `asset2`.
   * @notice The `fromToken` and `toToken` cannot be the same token.
   * @notice The `amount` must be greater than zero.
   * @notice The returned amount does not include any swap fees.
   */
  function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256) {
    require(fromToken != toToken, 'Cannot swap the same token');
    require(amount > 0, 'Amount must be greater than zero');
    uint256 fee = (amount * SWAP_FEE_BPS) / 10000;
    uint256 amountAfterFee = amount - fee;

    return _convertTokenWithRate(fromToken, toToken, amountAfterFee);
  }

  /**
   * @dev Adds liquidity to the pool by transferring specified amounts of assets from the caller's address to the contract.
   * The function calculates the received amount of each asset and mints new LP tokens proporzionalmente.
   * @param amounts An array of amounts for each asset to be added as liquidity.
   * @return The amount of LP tokens minted and transferred to the caller.
   */
  function addLiquidity(uint256[] calldata amounts) external nonReentrant returns (uint256) {
    require(amounts.length == assets.length, 'Amounts length mismatch');
    uint256 totalSupply = totalSupply();
    uint256 totalValueInFirstAsset = 0;

    for (uint256 i = 0; i < assets.length; i++) {
      address asset = assets[i];
      uint256 amount = amounts[i];
      IERC20(asset).transferFrom(msg.sender, address(this), amount);
      balances[asset] += amount;
      uint8 decimals = IERC20Metadata(asset).decimals();

      uint256 scalingFactor = 10 ** (18 - decimals);
      uint256 scalingAmount = amount * scalingFactor;
      uint256 fee = (scalingAmount * SWAP_FEE_BPS) / 10000;
      uint256 amountAfterFeeScaled = scalingAmount - fee;

      if (asset == assets[0]) {
        totalValueInFirstAsset += amountAfterFeeScaled;
      } else {
        uint256 amountInFirstAsset = _convertTokenWithRate(asset, assets[0], amountAfterFeeScaled);
        totalValueInFirstAsset += amountInFirstAsset;
      }
    }

    uint256 toMint;

    if (totalSupply == 0) {
      toMint = totalValueInFirstAsset;
    } else {
      uint256 totalLiquidity = totalLiquidityInToken(assets[0]);
      toMint = (totalValueInFirstAsset * totalSupply) / totalLiquidity;
    }

    _mint(msg.sender, toMint);
    emit LiquidityAdded(msg.sender, amounts, toMint);

    return toMint;
  }

  /**
   * @dev Calculates the total liquidity in terms of a specified token.
   * @param token The address of the token for which to calculate the total liquidity.
   * @return The total liquidity in terms of the specified token.
   */
  function totalLiquidityInToken(address token) public view returns (uint256) {
    uint256 totalLiquidity = 0;

    for (uint256 i = 0; i < assets.length; i++) {
      address t = assets[i];
      uint256 balance = balances[t];
      uint8 decimals = IERC20Metadata(t).decimals();
      uint256 scalingFactor = 10 ** (18 - decimals);

      uint256 valueInToken;
      if (t == token) {
        valueInToken = balance * scalingFactor;
      } else {
        valueInToken = _convertTokenWithRate(t, token, balance * scalingFactor);
      }
      totalLiquidity += valueInToken;
    }

    return totalLiquidity;
  }

  /**
   * @dev Checks if the given asset is supported by the pool.
   * @param asset The address of the asset to check.
   * @return True if the asset is supported, false otherwise.
   */
  function isAssetSupported(address asset) public view returns (bool) {
    for (uint256 i = 0; i < assets.length; i++) {
      if (assets[i] == asset) {
        return true;
      }
    }
    return false;
  }

  /**
   * @dev Allows a user to exit the pool by redeeming their share of assets.
   * @param share The amount of shares to redeem.
   * Requirements:
   * - The caller must have a balance of shares greater than or equal to the specified amount.
   * - The pool must have sufficient assets to cover the redeemed shares.
   * Effects:
   * - Decreases the caller's share balance by the specified amount.
   * - Transfers the proportional amount of each asset in the pool to the caller.
   * Emits:
   * - LiquidityRemoved event with the caller's address and the redeemed share amount.
   */
  function exit(uint256 share, address recipient) external nonReentrant {
    require(balanceOf(msg.sender) >= share, 'Insufficient share');
    uint256 totalSupply = totalSupply();
    require(totalSupply > 0, 'No liquidity');

    uint256[] memory amounts = new uint256[](assets.length);

    // Calculate the share of each asset to be transferred
    for (uint256 i = 0; i < assets.length; i++) {
      uint256 assetBalance = IERC20(assets[i]).balanceOf(address(this));
      amounts[i] = (assetBalance * share) / totalSupply;
    }

    // Burn the shares
    _burn(msg.sender, share);

    // Transfer each asset to the user
    for (uint256 i = 0; i < assets.length; i++) {
      IERC20(assets[i]).transfer(recipient, amounts[i]);
    }

    emit LiquidityRemoved(recipient, amounts, share);
  }

  /**
   * @dev Returns the total liquidity in asset1.
   * It calculates the total balance of asset1 held by the contract,
   * and also calculates the value of asset2 in terms of asset1.
   * The total liquidity is the sum of the asset1 balance and the value of asset2 in asset1.
   * @return The total liquidity in asset1.
   */

  /**
   * @dev Performs a rebalance if needed.
   *
   * This internal function checks if a rebalance is needed by calling the `checkRebalance` function of the `rebalancer` contract.
   * If a rebalance is required, it calls the `rebalance` function of the `rebalancer` contract to perform the rebalance.
   *
   * Requirements:
   * - The `assets` array must contain the addresses of the assets to rebalance.
   * - The `weights` array must contain the corresponding weights for the assets.
   * - The `rebalanceStatus` must not be `NoRebalance`.
   */
  function performRebalanceIfNeeded(address _sender) external {
    uint256 requiredBalance = (totalSupply() * 1000) / 10000;
    require(balanceOf(_sender) >= requiredBalance, 'Under 5% LP share');
    _performRebalanceIfNeeded();
  }

  /**
   * @dev Returns the deviation of the current weights of each asset from the target weights.
   * @return directions An array of booleans indicating whether each current weight is greater than the target weight.
   * @return deviations An array of uint256 values representing the deviation of each asset's current weight from the target weight.
   */
  function getDeviation() external view returns (bool[] memory directions, uint256[] memory deviations) {
    (uint256 totalUsdValuation, uint256[] memory usdValuations) = _computeValuation();
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

  /**
   * @dev Returns the valuation of a specific asset in USD.
   * @param assetIndex The index of the asset in the assets array.
   * @return The valuation of the specified asset in USD.
   */
  function assetToStable(uint256 assetIndex) external view returns (uint256) {
    (, uint256[] memory usdValuations) = _computeValuation();
    require(assetIndex < usdValuations.length, 'Invalid asset index');
    return usdValuations[assetIndex];
  }

  /**
   * @dev Returns the total valuation in USD.
   * @return The total valuation in USD.
   */
  function totalLiquidityStable() external view returns (uint256) {
    (uint256 totalVal, ) = _computeValuation();
    return totalVal;
  }

  /**
   * @dev Returns the unit price of the pool.
   * The unit price is calculated by dividing the total valuation of the pool by the total supply of tokens.
   * If the total supply is 0, the unit price is 0.
   * @return The unit price of the pool in USD.
   */
  function getUnitPriceStable() external view returns (uint256) {
    (uint256 totalVal, ) = _computeValuation();
    uint256 totalSupply = totalSupply();
    if (totalSupply == 0) {
      return 0;
    }
    return (totalVal * ONE) / totalSupply;
  }

  /**
   * @dev Computes the valuation of the assets in the pool.
   * @return totalValuation The total valuation of the assets in USD.
   * @return usdValuations An array of USD valuations for each asset.
   */
  function _computeValuation() internal view returns (uint256 totalValuation, uint256[] memory usdValuations) {
    uint256 numAssets = assets.length;
    usdValuations = new uint256[](numAssets);
    IBaluniV1Router baluniRouter = IBaluniV1Router(rebalancer.getBaluniRouter());

    for (uint256 i = 0; i < numAssets; i++) {
      IERC20 asset = IERC20(assets[i]);
      uint8 decimals = IERC20Metadata(address(asset)).decimals();
      uint256 price = baluniRouter.tokenValuation(1 * 10 ** decimals, address(asset));
      uint256 factor = 10 ** (18 - decimals);
      usdValuations[i] = (asset.balanceOf(address(this)) * factor * price) / ONE;
      totalValuation += usdValuations[i];
    }

    return (totalValuation, usdValuations);
  }

  /**
   * @dev Performs rebalance if needed based on the deviation of asset weights from the target weights.
   * @notice This function checks if the caller has any shares, calculates the current weights of assets,
   * and compares them with the target weights. If the deviation exceeds the threshold, a rebalance is performed
   * by calling the `rebalance` function of the `rebalancer` contract.
   * @notice The rebalance is performed using the assets and weights specified in the `assets` and `weights` arrays.
   * @notice Emits a `RebalancePerformed` event if a rebalance is performed.
   * @notice Reverts with an error message if no rebalance is needed.
   */
  function _performRebalanceIfNeeded() internal {
    rebalancer.rebalance(assets, weights, address(this), address(this), trigger);
    emit RebalancePerformed(msg.sender, assets);
  }

  /**
   * @dev Returns the current reserves of all assets held by the contract.
   * @return An array containing the balances of all assets respectively.
   */
  function getReserves() external view returns (uint256[] memory) {
    uint256[] memory reserves = new uint256[](assets.length);
    for (uint256 i = 0; i < assets.length; i++) {
      reserves[i] = IERC20(assets[i]).balanceOf(address(this));
    }
    return reserves;
  }

  function changeRebalancer(address _newRebalancer) external {
    require(msg.sender == address(factory), 'Only Factory');
    rebalancer = IBaluniV1Rebalancer(_newRebalancer);
  }

  function getAssets() external view returns (address[] memory) {
    return assets;
  }

  function getWeights() external view returns (uint256[] memory) {
    return weights;
  }

  event Swap(
    address indexed user,
    address indexed fromToken,
    address indexed toToken,
    uint256 amountIn,
    uint256 amountOut
  );
  event LiquidityAdded(address indexed user, uint256[] amounts, uint256 sharesMinted);
  event LiquidityRemoved(address indexed user, uint256 asset1Amount, uint256 asset2Amount, uint256 sharesBurned);
}
