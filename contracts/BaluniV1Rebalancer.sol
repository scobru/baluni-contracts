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
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import './interfaces/IBaluniV1Router.sol';
import './interfaces/IBaluniV1Rebalancer.sol';

interface I1inchSpotAgg {
  function getRate(IERC20 srcToken, IERC20 dstToken, bool useWrappers) external view returns (uint256 weightedRate);
}

contract BaluniV1Rebalancer is Initializable, OwnableUpgradeable, UUPSUpgradeable, IBaluniV1Rebalancer {
  uint256 internal multiplier;

  IBaluniV1Router public baluniRouter;
  IERC20 internal USDC;
  IERC20Metadata internal WNATIVE;
  ISwapRouter internal uniswapRouter;
  IUniswapV3Factory internal uniswapFactory;
  I1inchSpotAgg internal _1InchSpotAgg;

  /**
   * @dev Initializes the contract with the specified addresses and sets the multiplier value.
   * @param _baluniRouter The address of the BaluniV1Router contract.
   * @param _usdc The address of the USDC token contract.
   * @param _wnative The address of the WNATIVE token contract.
   * @param _uniRouter The address of the Uniswap router contract.
   * @param _uniFactory The address of the Uniswap factory contract.
   */
  function initialize(
    address _baluniRouter,
    address _usdc,
    address _wnative,
    address _uniRouter,
    address _uniFactory,
    address _1InchSpotAggAddress
  ) public initializer {
    // Initialize the contract
    __UUPSUpgradeable_init();
    __Ownable_init(msg.sender);

    // Set the token contracts and router contracts
    USDC = IERC20(_usdc);
    WNATIVE = IERC20Metadata(_wnative);
    uniswapRouter = ISwapRouter(_uniRouter);
    uniswapFactory = IUniswapV3Factory(_uniFactory);
    baluniRouter = IBaluniV1Router(_baluniRouter);
    _1InchSpotAgg = I1inchSpotAgg(_1InchSpotAggAddress);

    // Set the multiplier value
    multiplier = 1e12;
  }

  /**
   * @dev Reinitializes the contract with the specified addresses and sets the multiplier value.
   * @param _baluniRouter The address of the BaluniV1Router contract.
   * @param _usdc The address of the USDC token contract.
   * @param _wnative The address of the WNATIVE token contract.
   * @param _uniRouter The address of the Uniswap router contract.
   * @param _uniFactory The address of the Uniswap factory contract.
   * @param version The version of the contract.
   */
  function reinitialize(
    address _baluniRouter,
    address _usdc,
    address _wnative,
    address _uniRouter,
    address _uniFactory,
    uint64 version
  ) public reinitializer(version) {
    // Set the token contracts and router contracts
    USDC = IERC20(_usdc);
    WNATIVE = IERC20Metadata(_wnative);
    uniswapRouter = ISwapRouter(_uniRouter);
    uniswapFactory = IUniswapV3Factory(_uniFactory);
    baluniRouter = IBaluniV1Router(_baluniRouter);

    // Set the multiplier value
    multiplier = 1e12;
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  /**
   * @dev Rebalances the assets in the contract based on the specified weights.
   * @param assets An array of asset addresses.
   * @param weights An array of weights corresponding to the assets.
   * @param receiver The address that will receive the rebalanced assets.
   * @param limit The maximum percentage difference allowed between the current weight and target weight.
   */
  function rebalance(
    address[] calldata assets,
    uint256[] calldata weights,
    address sender,
    address receiver,
    uint256 limit
  ) external override {
    RebalanceVars memory vars = _checkRebalance(assets, weights, limit, sender);

    for (uint256 i = 0; i < vars.overweightVaults.length; i++) {
      if (vars.overweightAmounts[i] > 0) {
        address asset = assets[vars.overweightVaults[i]];

        require(vars.balances[i] >= vars.overweightAmounts[i], 'Balance under overweight amounts');
        IERC20(asset).transferFrom(sender, address(this), vars.overweightAmounts[i]);

        if (asset == address(USDC)) {
          continue;
        }

        secureApproval(asset, address(uniswapRouter), vars.overweightAmounts[i]);

        if (asset == address(WNATIVE)) {
          vars.amountOut += _singleSwap(asset, address(USDC), vars.overweightAmounts[i], address(this));
        } else {
          vars.amountOut += _multiHopSwap(
            asset,
            address(WNATIVE),
            address(USDC),
            vars.overweightAmounts[i],
            address(this)
          );
        }
      }
    }

    uint256 usdBalance = USDC.balanceOf(address(this));
    require(usdBalance >= vars.amountOut, 'Insufficient USDC Balance');

    for (uint256 i = 0; i < vars.underweightVaults.length; i++) {
      if (vars.underweightAmounts[i] > 0) {
        address asset = assets[vars.underweightVaults[i]];

        uint256 rebaseActiveWgt = (vars.underweightAmounts[i] * 10000) / vars.totalActiveWeight;
        uint256 rebBuyQty = (rebaseActiveWgt * usdBalance * 1e12) / 10000;

        if (asset == address(USDC)) {
          IERC20(USDC).transfer(receiver, rebBuyQty / 1e12);
          continue;
        }

        if (rebBuyQty > 0 && rebBuyQty <= usdBalance * 1e12) {
          secureApproval(address(USDC), address(uniswapRouter), rebBuyQty / 1e12);
          require(usdBalance >= rebBuyQty / 1e12, 'Balance under RebuyQty');

          address treasury = baluniRouter.getTreasury();

          uint256 amountOut;
          if (asset == address(WNATIVE)) {
            amountOut = _singleSwap(address(USDC), address(WNATIVE), rebBuyQty / 1e12, address(this));
          } else {
            amountOut = _multiHopSwap(address(USDC), address(WNATIVE), asset, rebBuyQty / 1e12, address(this));
          }

          vars.amountOut = amountOut;

          uint256 amountToReceiver = calculateNetAmountAfterFee(amountOut);
          uint256 remainingToReceiver = amountOut - amountToReceiver;
          uint256 amountToRouter = calculateNetAmountAfterFee(remainingToReceiver);
          uint256 amountToTreasury = remainingToReceiver - amountToRouter;

          require(IERC20(asset).balanceOf(address(this)) >= amountToReceiver, 'Balance under amountToTransfer');

          IERC20(asset).transfer(address(receiver), amountToReceiver);
          IERC20(asset).transfer(address(baluniRouter), amountToRouter);
          IERC20(asset).transfer(address(treasury), amountToTreasury);
        }
      }
    }
  }

  /**
   * @dev Checks if a rebalance is needed based on the given assets, weights, limit, and sender.
   * @param assets The array of addresses representing the assets to be rebalanced.
   * @param weights The array of weights corresponding to the assets.
   * @param limit The maximum limit for the rebalance.
   * @param sender The address of the sender.
   * @return A struct containing the rebalance variables.
   */
  function checkRebalance(
    address[] calldata assets,
    uint256[] calldata weights,
    uint256 limit,
    address sender
  ) public view override returns (RebalanceVars memory) {
    return _checkRebalance(assets, weights, limit, sender);
  }

  /**
   * @dev Internal function to check if rebalancing is required for a given set of assets and weights.
   * @param assets The array of asset addresses.
   * @param weights The array of target weights for each asset.
   * @param limit The maximum percentage difference allowed between the current weight and target weight.
   * @param sender The address of the sender.
   * @return A `RebalanceVars` struct containing the rebalance information.
   */
  function _checkRebalance(
    address[] calldata assets,
    uint256[] calldata weights,
    uint256 limit,
    address sender
  ) internal view returns (RebalanceVars memory) {
    uint256 totalValue = calculateTotalValue(assets, sender);
    RebalanceVars memory vars = RebalanceVars(
      assets.length,
      totalValue,
      0,
      0,
      0,
      0,
      0,
      new uint256[](assets.length * 2),
      new uint256[](assets.length * 2),
      new uint256[](assets.length * 2),
      new uint256[](assets.length * 2),
      new uint256[](assets.length)
    );

    for (uint256 i = 0; i < assets.length; i++) {
      vars.balances[i] = IERC20(assets[i]).balanceOf(sender);
      uint256 decimals = IERC20Metadata(assets[i]).decimals();
      uint256 tokensTotalValue;

      uint256 price = baluniRouter.tokenValuation(1 * 10 ** decimals, assets[i]);

      if (assets[i] == address(USDC)) {
        tokensTotalValue = vars.balances[i] * 1e12; // Adjust for USDC decimals (assumed to be 6)
      } else {
        tokensTotalValue = (price * vars.balances[i] * (10 ** (18 - decimals))) / 1e18; // Correctly adjust for token decimals
      }

      uint256 targetWeight = weights[i];
      uint256 currentWeight = (tokensTotalValue * 10000) / totalValue;
      bool overweight = currentWeight > targetWeight;
      uint256 overweightPercent = overweight ? currentWeight - targetWeight : targetWeight - currentWeight;

      if (overweight && overweightPercent > limit) {
        uint256 overweightAmount = (overweightPercent * totalValue) / 10000;
        vars.finalUsdBalance += overweightAmount;

        overweightAmount = (overweightAmount * 1e18) / price;
        overweightAmount = overweightAmount / (10 ** (18 - decimals));
        vars.overweightVaults[vars.overweightVaultsLength] = i;
        vars.overweightAmounts[vars.overweightVaultsLength] = overweightAmount;
        vars.overweightVaultsLength++;
      } else if (!overweight && overweightPercent > limit) {
        vars.totalActiveWeight += overweightPercent;
        vars.underweightVaults[vars.underweightVaultsLength] = i;
        vars.underweightAmounts[vars.underweightVaultsLength] = overweightPercent;
        vars.underweightVaultsLength++;
      }
    }

    vars.overweightVaults = _resize(vars.overweightVaults, vars.overweightVaultsLength);
    vars.overweightAmounts = _resize(vars.overweightAmounts, vars.overweightVaultsLength);
    vars.underweightVaults = _resize(vars.underweightVaults, vars.underweightVaultsLength);
    vars.underweightAmounts = _resize(vars.underweightAmounts, vars.underweightVaultsLength);

    return vars;
  }

  /**
   * @dev Resizes an array to a specified size.
   * @param arr The original array to be resized.
   * @param size The new size for the array.
   * @return ret The resized array.
   */
  function _resize(uint256[] memory arr, uint256 size) internal pure returns (uint256[] memory) {
    uint256[] memory ret = new uint256[](size);
    for (uint256 i; i < size; i++) {
      ret[i] = arr[i];
    }
    return ret;
  }

  /**
   * @dev Ensures that the contract has the necessary approval for a token to be spent by a spender.
   * If the current allowance is not equal to the desired amount, it updates the allowance accordingly.
   * @param token The address of the token to be approved.
   * @param spender The address of the spender.
   * @param amount The desired allowance amount.
   * @notice This function is internal and should not be called directly.
   */
  function secureApproval(address token, address spender, uint256 amount) internal {
    IERC20 _token = IERC20(token);
    // check allowance thena pprove
    if (_token.allowance(address(this), spender) < amount) {
      _token.approve(spender, 0);
      _token.approve(spender, amount);
    }
  }

  /**
   * @dev Executes a single swap between two tokens using Uniswap.
   * @param token0 The address of the token to be swapped.
   * @param token1 The address of the token to be received.
   * @param amount The amount of token0 to be swapped.
   * @param receiver The address that will receive the swapped tokens.
   * @return amountOut The amount of token1 received from the swap.
   *
   * The function requires that the caller has a sufficient balance of token0 and that the amount to be swapped is greater than 0.
   * Also, the caller must have approved this contract to spend the amount of token0.
   * The function transfers the amount of token0 to be swapped from the caller to this contract, then performs the swap using Uniswap.
   * The swapped tokens are sent to the receiver's address.
   * The function returns the amount of token1 received from the swap.
   */
  function singleSwap(
    address token0,
    address token1,
    uint256 amount,
    address receiver
  ) external returns (uint256 amountOut) {
    require(msg.sender != address(this), 'Wrong sender');
    require(amount > 0, 'Amount is 0');
    require(IERC20(token0).balanceOf(msg.sender) >= amount, 'Insufficient Balance');
    IERC20(token0).transferFrom(msg.sender, address(this), amount);
    secureApproval(token0, address(uniswapRouter), amount);
    return _singleSwap(token0, token1, amount, receiver);
  }

  /**
   * @dev Executes a multi-hop swap between three tokens using Uniswap.
   * @param token0 The address of the token to be swapped.
   * @param token1 The address of the intermediate token to be used for the swap.
   * @param token2 The address of the final token to be received.
   * @param amount The amount of token0 to be swapped.
   * @param receiver The address that will receive the swapped tokens.
   * @return amountOut The amount of token2 received from the swap.
   *
   * The function requires that the caller has a sufficient balance of token0 and that the amount to be swapped is greater than 0.
   * Also, the caller must have approved this contract to spend the amount of token0.
   * The function transfers the amount of token0 to be swapped from the caller to this contract, then performs the swap using Uniswap.
   * The swapped tokens are sent to the receiver's address.
   * The function returns the amount of token2 received from the swap.
   */
  function multiHopSwap(
    address token0,
    address token1,
    address token2,
    uint256 amount,
    address receiver
  ) external returns (uint256 amountOut) {
    require(msg.sender != address(this), 'Wrong sender');
    require(amount > 0, 'Amount is 0');
    require(IERC20(token0).balanceOf(msg.sender) >= amount, 'Insufficient Balance');
    IERC20(token0).transferFrom(msg.sender, address(this), amount);
    secureApproval(token0, address(uniswapRouter), amount);
    return _multiHopSwap(token0, token1, token2, amount, receiver);
  }

  /**
   * @dev Executes a single swap on Uniswap.
   * @param token0 The address of the input token.
   * @param token1 The address of the output token.
   * @param tokenBalance The amount of input token to be swapped.
   * @param receiver The address that will receive the swapped tokens.
   * @return amountOut The amount of output tokens received.
   */
  function _singleSwap(
    address token0,
    address token1,
    uint256 tokenBalance,
    address receiver
  ) private returns (uint256) {
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
      tokenIn: token0,
      tokenOut: token1,
      fee: 3000,
      recipient: address(receiver),
      deadline: block.timestamp + 60, // Adding a 5-minute buffer
      amountIn: tokenBalance,
      amountOutMinimum: 1,
      sqrtPriceLimitX96: 0
    });

    uint256 amountOut = uniswapRouter.exactInputSingle(params);
    require(amountOut >= 0, 'Uniswap swap failed to meet minimum amount out');
    return amountOut;
  }

  /**
   * @dev Executes a multi-hop swap using the Uniswap router.
   * @param token0 The address of the first token in the swap path.
   * @param token1 The address of the second token in the swap path.
   * @param token2 The address of the third token in the swap path.
   * @param tokenBalance The amount of tokens to be swapped.
   * @param receiver The address that will receive the swapped tokens.
   * @return amountOut The amount of tokens received after the swap.
   */
  function _multiHopSwap(
    address token0,
    address token1,
    address token2,
    uint256 tokenBalance,
    address receiver
  ) private returns (uint256) {
    ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
      path: abi.encodePacked(token0, uint24(3000), token1, uint24(3000), token2),
      recipient: address(receiver),
      deadline: block.timestamp + 60, // Adding a 5-minute buffer
      amountIn: tokenBalance,
      amountOutMinimum: 1
    });
    uint256 amountOut = uniswapRouter.exactInput(params);
    require(amountOut >= 0, 'Uniswap swap failed to meet minimum amount out');
    return amountOut;
  }

  /**
   * @dev Calculates the net amount after applying a fee.
   * @param _amount The initial amount before the fee is applied.
   * @return The net amount after the fee has been applied.
   *
   * The function uses the Basis Point (BPS) system for fee calculation.
   * 1 BPS is 1/100 of a percent or 0.01% hence the BPS base is 10000.
   * The function retrieves the BPS fee from the baluniRouter and calculates the net amount.
   * The fee is subtracted from the BPS base and the result is multiplied with the initial amount.
   * The product is then divided by the BPS base to get the net amount.
   */
  function calculateNetAmountAfterFee(uint256 _amount) internal view returns (uint256) {
    uint256 _BPS_BASE = 10000;
    uint256 _BPS_FEE = baluniRouter.getBpsFee();
    uint256 amountInWithFee = (_amount * (_BPS_BASE - (_BPS_FEE))) / _BPS_BASE;
    return amountInWithFee;
  }

  /**
   * @dev Calculates the total value of the assets held by the caller.
   * @param assets An array of asset addresses.
   * @return The total value of the assets held by the caller.
   */
  function calculateTotalValue(address[] memory assets, address user) private view returns (uint256) {
    uint256 _tokenValue = 0;
    for (uint256 i = 0; i < assets.length; i++) {
      uint256 balance = IERC20(assets[i]).balanceOf(user);

      if (assets[i] == address(USDC)) {
        _tokenValue += balance * 1e12;
      } else {
        _tokenValue += baluniRouter.tokenValuation(balance, assets[i]);
      }
    }

    return _tokenValue;
  }

  /**
   * @dev Changes the Baluni router address.
   * Can only be called by the contract owner.
   *
   * @param _newRouter The new address of the Baluni router.
   */
  function changeBaluniRouter(address _newRouter) external onlyOwner {
    baluniRouter = IBaluniV1Router(_newRouter);
  }

  /**
   * @dev Returns the address of the Baluni Router contract.
   * @return The address of the Baluni Router contract.
   */
  function getBaluniRouter() external view returns (address) {
    return address(baluniRouter);
  }

  /**
   * @dev Returns the weighted rate between two tokens.
   * @param srcToken The source token.
   * @param dstToken The destination token.
   * @param useWrappers Boolean indicating whether to use wrappers.
   * @return weightedRate The weighted rate between the source and destination tokens.
   */
  function getRate(IERC20 srcToken, IERC20 dstToken, bool useWrappers) external view returns (uint256 weightedRate) {
    uint256 rate;
    uint8 token0Decimal = IERC20Metadata(address(srcToken)).decimals();
    uint8 token1Decimal = IERC20Metadata(address(dstToken)).decimals();
    uint256 amount = 1 * 18 ** token0Decimal;

    try _1InchSpotAgg.getRate(IERC20(srcToken), IERC20(dstToken), false) returns (uint256 _rate) {
      rate = _rate;
    } catch {
      return 0;
    }

    if (token0Decimal == token1Decimal) return ((amount * 1e12) * (rate)) / 1e18;
    uint256 factor = (10 ** (token0Decimal - token1Decimal));

    if (token0Decimal < 18) return ((amount * factor) * (rate * factor)) / 1e18;
    return ((amount) * (rate * factor)) / 1e18;
  }
}
