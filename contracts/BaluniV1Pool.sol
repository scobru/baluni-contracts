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

interface AggregatorV3Interface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  function decimals() external view returns (uint8);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

contract BaluniV1Pool is ERC20, ReentrancyGuard {
  IBaluniV1Rebalancer public rebalancer;
  IERC20 public asset1;
  IERC20 public asset2;

  AggregatorV3Interface public oracle;

  uint256 public constant SWAP_FEE_BPS = 30;
  uint256 public weight1;
  uint256 public weight2;
  uint256 public trigger;

  uint256 public ONE = 1e18;

  address public factory;

  event RebalancePerformed(address indexed by, address[] assets);

  /**
   * @dev Initializes the BaluniV1Pool contract.
   * @param _oracle The address of the oracle contract.
   * @param _rebalancer The address of the rebalancer contract.
   * @param assets The addresses of the asset contracts.
   * @param weights The weights of the assets.
   * @param _trigger The trigger value.
   */
  constructor(
    address _oracle,
    address _rebalancer,
    address[] memory assets,
    uint256[] memory weights,
    uint256 _trigger
  ) ERC20('Baluni LP', 'BALUNI-LP') ReentrancyGuard() {
    factory = msg.sender;
    rebalancer = IBaluniV1Rebalancer(_rebalancer);
    asset1 = IERC20(assets[0]);
    asset2 = IERC20(assets[1]);
    oracle = AggregatorV3Interface(_oracle);
    asset1.approve(address(rebalancer), type(uint256).max);
    asset2.approve(address(rebalancer), type(uint256).max);
    weight1 = weights[0];
    weight2 = weights[1];
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
    uint256 rate = uint256(oracle.latestAnswer()); // Convert int256 to uint256
    uint256 adjustedRate = rate * (10 ** (18 - oracle.decimals())); // Adjust for the decimals
    uint8 fromDecimals = IERC20Metadata(fromToken).decimals();
    uint8 toDecimals = IERC20Metadata(toToken).decimals();
    require(fromDecimals <= 18, 'FromToken has more than 18 decimals');
    require(toDecimals <= 18, 'ToToken has more than 18 decimals');

    uint256 adjustedAmount = amountAfterFee * adjustedRate;
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
    require(
      (fromToken == address(asset1) || fromToken == address(asset2)) &&
        (toToken == address(asset1) || toToken == address(asset2)),
      'Unsupported token'
    );
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
    require(
      (fromToken == address(asset1) || fromToken == address(asset2)) &&
        (toToken == address(asset1) || toToken == address(asset2)),
      'Unsupported token'
    );
    require(fromToken != toToken, 'Cannot swap the same token');
    require(amount > 0, 'Amount must be greater than zero');

    uint256 fee = (amount * SWAP_FEE_BPS) / 10000;
    uint256 amountAfterFee = amount - fee;

    return _convertTokenWithRate(fromToken, toToken, amountAfterFee);
  }

  /**
   * @dev Adds liquidity to the pool by transferring `amount1` of `asset1` and `amount2` of `asset2` from the caller's address to the contract.
   * The function calculates the received amount of `asset2` based on the amount of `asset1` added, and then calculates the total value in `asset2`.
   * If the total supply of the pool is 0, the function mints new tokens to the caller based on the total value in `asset2`.
   * If the total supply is not 0, the function calculates the total liquidity in `asset2` and mints new tokens to the caller proportionally.
   * Emits a `LiquidityAdded` event with the caller's address, `amount1`, `amount2`, and the amount of tokens minted (`toMint`).
   * @param amount1 The amount of `asset1` to be added as liquidity.
   * @param amount2 The amount of `asset2` to be added as liquidity.
   * @return The amount of tokens (`toMint`) minted and transferred to the caller.
   */
  function addLiquidity(uint256 amount1, uint256 amount2) external nonReentrant returns (uint256) {
    asset1.transferFrom(msg.sender, address(this), amount1);
    asset2.transferFrom(msg.sender, address(this), amount2);

    uint256 amount1InAsset2 = _convertTokenWithRate(address(asset1), address(asset2), amount1);
    uint256 totalValueInAsset2 = amount1InAsset2 + amount2;

    uint256 totalSupply = totalSupply();
    uint256 toMint;

    if (totalSupply == 0) {
      toMint = (totalValueInAsset2 * ONE) / 10 ** IERC20Metadata(address(asset2)).decimals();
    } else {
      uint256 totalLiquidity = totalLiquidityAsset2();
      toMint = (totalValueInAsset2 * totalSupply) / totalLiquidity;
    }

    _mint(msg.sender, toMint);
    emit LiquidityAdded(msg.sender, amount1, amount2, toMint);

    return toMint;
  }

  /**
   * @dev Allows a user to exit the pool by redeeming their share of assets.
   * @param share The amount of shares to redeem.
   * Requirements:
   * - The caller must have a balance of shares greater than or equal to the specified amount.
   * - The pool must have sufficient assets to cover the redeemed shares.
   * Effects:
   * - Decreases the caller's share balance by the specified amount.
   * - Transfers the proportional amount of asset1 and asset2 to the caller.
   * Emits:
   * - LiquidityRemoved event with the caller's address, redeemed asset1 amount, redeemed asset2 amount, and the redeemed share amount.
   */
  function exit(uint256 share) external nonReentrant {
    require(balanceOf(msg.sender) >= share, 'Insufficient share');

    uint256 totalSupply = totalSupply();
    uint256 asset1Balance = asset1.balanceOf(address(this));
    uint256 asset2Balance = asset2.balanceOf(address(this));

    uint256 asset1Share = (asset1Balance * share) / totalSupply;
    uint256 asset2Share = (asset2Balance * share) / totalSupply;

    _burn(msg.sender, share);
    asset1.transfer(msg.sender, asset1Share);
    asset2.transfer(msg.sender, asset2Share);

    emit LiquidityRemoved(msg.sender, asset1Share, asset2Share, share);
  }

  /**
   * @dev Returns the total liquidity in asset1.
   * It calculates the total balance of asset1 held by the contract,
   * and also calculates the value of asset2 in terms of asset1.
   * The total liquidity is the sum of the asset1 balance and the value of asset2 in asset1.
   * @return The total liquidity in asset1.
   */

  function totalLiquidityAsset1() public view returns (uint256) {
    uint256 totalAsset1 = asset1.balanceOf(address(this));
    uint256 totalAsset2ValueInAsset1 = _convertTokenWithRate(
      address(asset2),
      address(asset1),
      asset2.balanceOf(address(this))
    );

    return totalAsset1 + totalAsset2ValueInAsset1;
  }

  /**
   * @dev Returns the total liquidity in asset2.
   * The total liquidity is calculated by summing the balance of asset2 held by the contract
   * and the value of asset1 converted to asset2 using the _convertTokenWithRate function.
   * @return The total liquidity in asset2.
   */
  function totalLiquidityAsset2() public view returns (uint256) {
    uint256 totalAsset2 = asset2.balanceOf(address(this));
    uint256 totalAsset1ValueInAsset2 = _convertTokenWithRate(
      address(asset1),
      address(asset2),
      asset1.balanceOf(address(this))
    );

    return totalAsset2 + totalAsset1ValueInAsset2;
  }

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
  function performRebalanceIfNeeded() external {
    uint256 requiredBalance = (totalSupply() * 1000) / 10000;
    require(balanceOf(msg.sender) >= requiredBalance, 'Under 5% LP share');
    _performRebalanceIfNeeded();
  }

  /**
   * @dev Returns the deviation of the current weights of asset1 and asset2 from the target weights.
   * @return deviationAsset1 The deviation of the current weight of asset1 from the target weight.
   * @return deviationAsset2 The deviation of the current weight of asset2 from the target weight.
   */
  function getDeviation() external view returns (bool, uint256, bool, uint256) {
    (uint256 totalUsdValuation, uint256 totalUsdValuationAsset1, uint256 totalUsdValuationAsset2) = _computeValuation();
    uint256 currentWeightAsset1 = (totalUsdValuationAsset1 * 10000) / totalUsdValuation;
    uint256 currentWeightAsset2 = (totalUsdValuationAsset2 * 10000) / totalUsdValuation;
    bool direction1;
    bool direction2;
    uint256 deviationAsset1 = currentWeightAsset1 > weight1
      ? currentWeightAsset1 - weight1
      : weight1 - currentWeightAsset1;

    direction1 = currentWeightAsset1 > weight1;

    uint256 deviationAsset2 = currentWeightAsset2 > weight2
      ? currentWeightAsset2 - weight2
      : weight2 - currentWeightAsset2;

    direction2 = currentWeightAsset2 > weight2;

    return (direction1, deviationAsset1, direction2, deviationAsset2);
  }

  /**
   * @dev Computes the valuation of the assets in the pool.
   * @return totalValuation The total valuation of the assets in USD.
   * @return totalUsdValuationAsset1 The valuation of asset1 in USD.
   * @return totalUsdValuationAsset2 The valuation of asset2 in USD.
   */
  function _computeValuation() internal view returns (uint256, uint256, uint256) {
    IBaluniV1Router baluniRouter = IBaluniV1Router(rebalancer.getBaluniRouter());
    uint8 decimal1 = IERC20Metadata(address(asset1)).decimals();
    uint8 decimal2 = IERC20Metadata(address(asset2)).decimals();
    uint256 priceAsset1 = baluniRouter.tokenValuation(1 * 10 ** decimal1, address(asset1));
    uint256 priceAsset2 = baluniRouter.tokenValuation(1 * 10 ** decimal1, address(asset2));
    uint256 factor1 = 10 ** 18 - decimal1;
    uint256 factor2 = 10 ** 18 - decimal2;
    uint256 totalUsdValuationAsset1 = ((IERC20(asset1).balanceOf(address(this)) * factor1) * priceAsset1) / ONE;
    uint256 totalUsdValuationAsset2 = ((IERC20(asset2).balanceOf(address(this)) * factor2) * priceAsset2) / ONE;
    uint256 totVal = totalUsdValuationAsset1 + totalUsdValuationAsset2;
    return (totVal, totalUsdValuationAsset1, totalUsdValuationAsset2);
  }

  /**
   * @dev Returns the valuation of asset 1 in USD.
   * @return The valuation of asset 1 in USD.
   */
  function asset1ToStable() external view returns (uint256) {
    (, uint256 totalUsdValuationAsset1, ) = _computeValuation();
    return totalUsdValuationAsset1;
  }

  /**
   * @dev Returns the valuation of asset 2 in USD.
   * @return The valuation of asset 2 in USD.
   */
  function asset2ToStable() external view returns (uint256) {
    (, , uint256 totalUsdValuationAsset2) = _computeValuation();
    return totalUsdValuationAsset2;
  }

  /**
   * @dev Returns the total valuation in USD.
   * @return The total valuation in USD.
   */
  function totalLiquidityStable() external view returns (uint256) {
    (uint256 totalVal, , ) = _computeValuation();
    return totalVal;
  }

  /**
   * @dev Returns the unit price of the pool.
   * The unit price is calculated by dividing the total valuation of the pool by the total supply of tokens.
   * If the total supply is 0, the unit price is 0.
   * @return The unit price of the pool in USD.
   */
  function getUnitPriceStable() external view returns (uint256) {
    (uint256 totalVal, , ) = _computeValuation();
    uint256 totalSupply = totalSupply();
    if (totalSupply == 0) {
      return 0;
    }
    return (totalVal / totalSupply) * ONE;
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
    uint256[] memory weights = new uint256[](2);
    weights[0] = weight1;
    weights[1] = weight2;

    address[] memory assets = new address[](2);
    assets[0] = address(asset1);
    assets[1] = address(asset2);

    rebalancer.rebalance(assets, weights, address(this), address(this), trigger);
    emit RebalancePerformed(msg.sender, assets);
  }

  /**
   * @dev Returns the current reserves of asset1 and asset2 held by the contract.
   * @return A tuple containing the balances of asset1 and asset2 respectively.
   */
  function getReserves() external view returns (uint256, uint256) {
    return (asset1.balanceOf(address(this)), asset2.balanceOf(address(this)));
  }

  function changeOracle(address _newOracle) external {
    require(msg.sender == address(factory), 'Only Factory');
    oracle = AggregatorV3Interface(_newOracle);
  }

  function changeRebalancer(address _newRebalancer) external {
    require(msg.sender == address(factory), 'Only Factory');
    rebalancer = IBaluniV1Rebalancer(_newRebalancer);
  }

  event Swap(
    address indexed user,
    address indexed fromToken,
    address indexed toToken,
    uint256 amountIn,
    uint256 amountOut
  );
  event LiquidityAdded(address indexed user, uint256 amount1, uint256 amount2, uint256 sharesMinted);
  event LiquidityRemoved(address indexed user, uint256 asset1Amount, uint256 asset2Amount, uint256 sharesBurned);
}
