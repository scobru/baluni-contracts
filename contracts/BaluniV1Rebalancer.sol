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
import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import './interfaces/IBaluniV1Router.sol';
import './interfaces/IBaluniV1Rebalancer.sol';

interface IOracle {
  function getRate(
    IERC20Upgradeable srcToken,
    IERC20Upgradeable dstToken,
    bool useWrappers
  ) external view returns (uint256 weightedRate);
}

contract BaluniV1Rebalancer is
  Initializable,
  OwnableUpgradeable,
  UUPSUpgradeable,
  IBaluniV1Rebalancer
{
  uint256 private multiplier;

  IBaluniV1Router public baluniRouter;
  IERC20Upgradeable private USDC;
  IERC20MetadataUpgradeable private WNATIVE;
  IOracle private oracle;
  ISwapRouter private uniswapRouter;
  IUniswapV3Factory private uniswapFactory;

  /**
   * @dev Initializes the contract.
   * @param _baluniRouter The address of the BaluniV1Router contract.
   *
   * This function is a public initializer function that sets up the contract.
   * It initializes the UUPSUpgradeable and Ownable contracts from which this contract inherits.
   * It also sets the addresses of the USDC, WNATIVE, oracle, uniswapRouter, uniswapFactory, and baluniRouter contracts.
   * The oracle is set to the address of the 1inch Spot Aggregator.
   * The multiplier is set to 1e12.
   */
  function initialize(
    address _baluniRouter,
    address _usdc,
    address _wnative,
    address _oracle,
    address _uniRouter,
    address _uniFactory
  ) public initializer {
    __UUPSUpgradeable_init();
    __Ownable_init();
    USDC = IERC20Upgradeable(_usdc);
    WNATIVE = IERC20MetadataUpgradeable(_wnative);
    oracle = IOracle(_oracle); // 1inch Spot Aggregator
    uniswapRouter = ISwapRouter(_uniRouter);
    uniswapFactory = IUniswapV3Factory(_uniFactory);
    baluniRouter = IBaluniV1Router(_baluniRouter);
    multiplier = 1e12;
  }

  function _authorizeUpgrade(
    address newImplementation
  ) internal override onlyOwner {}

  function adjustWeights(
    address[] memory assets,
    uint256[] memory weights,
    uint256 totalValue,
    address sender,
    address receiver
  ) private {
    uint256 overweightVaultsLength;
    uint256 underweightVaultsLength;
    uint256 overweightAmount;
    uint256 overweightPercent;
    uint256 targetWeight;
    uint256 currentWeight;
    uint256 totalActiveWeight;
    uint256 amountOut;
    bool overweight;

    uint256[] memory overweightVaults = new uint256[](assets.length);
    uint256[] memory overweightAmounts = new uint256[](assets.length);
    uint256[] memory underweightVaults = new uint256[](assets.length);
    uint256[] memory underweightAmounts = new uint256[](assets.length);

    for (uint256 i = 0; i < assets.length; i++) {
      uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(sender);
      uint256 decimals = IERC20MetadataUpgradeable(assets[i]).decimals();
      uint256 tokensTotalValue;
      if (assets[i] == address(USDC)) {
        tokensTotalValue = balance * 1e12;
      } else {
        tokensTotalValue = getTokenValuation(balance, assets[i]);
      }
      targetWeight = weights[i];
      currentWeight = (tokensTotalValue * (10000)) / (totalValue);
      overweight = currentWeight > targetWeight;
      overweightPercent = overweight
        ? currentWeight - (targetWeight)
        : targetWeight - (currentWeight);
      uint256 price = baluniRouter.tokenValuation(
        1 * 10 ** decimals,
        assets[i]
      );

      if (overweight) {
        overweightAmount = (overweightPercent * (totalValue)) / (10000);
        overweightAmount = (overweightAmount * (1e18)) / (price);
        if (decimals != uint8(18)) {
          overweightAmount = overweightAmount / (10 ** (18 - decimals));
        }
        overweightVaults[overweightVaultsLength] = i;
        overweightAmounts[overweightVaultsLength] = overweightAmount;
        overweightVaultsLength++;
      } else if (!overweight) {
        totalActiveWeight += overweightPercent;
        overweightAmount = overweightPercent;
        // overweightAmount = overweightPercent.mul(totalValue).div(10000);
        underweightVaults[underweightVaultsLength] = i;
        underweightAmounts[underweightVaultsLength] = overweightAmount;
        underweightVaultsLength++;
      }
    }

    overweightVaults = _resize(overweightVaults, overweightVaultsLength);
    overweightAmounts = _resize(overweightAmounts, overweightVaultsLength);
    underweightVaults = _resize(underweightVaults, underweightVaultsLength);
    underweightAmounts = _resize(underweightAmounts, underweightVaultsLength);

    for (uint256 i; i < overweightVaults.length; i++) {
      if (overweightAmounts[i] > 0) {
        address asset = assets[overweightVaults[i]];

        require(
          IERC20Upgradeable(asset).balanceOf(sender) >= overweightAmounts[i],
          'Balance under overweight amounts'
        );
        IERC20Upgradeable(address(asset)).transferFrom(
          sender,
          address(this),
          overweightAmounts[i]
        );
        address pool = uniswapFactory.getPool(asset, address(USDC), 3000);
        secureApproval(asset, address(uniswapRouter), overweightAmounts[i]);

        if (pool != address(0)) {
          amountOut += _singleSwap(
            asset,
            address(USDC),
            overweightAmounts[i],
            address(this)
          );
        } else {
          amountOut += _multiHopSwap(
            asset,
            address(WNATIVE),
            address(USDC),
            overweightAmounts[i],
            address(this)
          );
        }
      }
    }

    require(
      USDC.balanceOf(address(this)) >= amountOut,
      'Insufficient USDC Balance'
    );

    for (uint256 i; i < underweightVaults.length; i++) {
      if (underweightAmounts[i] > 0) {
        address asset = assets[underweightVaults[i]];
        uint256 rebaseActiveWgt = (underweightAmounts[i] * (10000)) /
          (totalActiveWeight);
        uint256 rebBuyQty = (rebaseActiveWgt *
          IERC20Upgradeable(USDC).balanceOf(address(this)) *
          1e12) / (10000);

        if (asset == address(USDC)) {
          IERC20Upgradeable(address(USDC)).transfer(receiver, rebBuyQty / 1e12);
          return;
        }

        if (
          rebBuyQty > 0 &&
          rebBuyQty <= IERC20Upgradeable(USDC).balanceOf(address(this)) * 1e12
        ) {
          address pool = uniswapFactory.getPool(asset, address(USDC), 3000);
          secureApproval(
            address(USDC),
            address(uniswapRouter),
            rebBuyQty / 1e12
          );
          require(
            IERC20Upgradeable(USDC).balanceOf(address(this)) >=
              rebBuyQty / 1e12,
            'Balance under RebuyQty'
          );

          address treasury = baluniRouter.getTreasury();

          if (pool != address(0)) {
            uint256 singleSwapResult = _singleSwap(
              address(USDC),
              address(assets[underweightVaults[i]]),
              rebBuyQty / 1e12,
              address(this)
            );

            uint256 amountToReceiver = calculateNetAmountAfterFee(
              singleSwapResult
            );
            uint256 remainingToReceiver = singleSwapResult - amountToReceiver;
            uint256 amountToRouter = calculateNetAmountAfterFee(
              remainingToReceiver
            );
            uint256 amountToTreasury = remainingToReceiver - amountToRouter;

            require(
              IERC20Upgradeable(asset).balanceOf(address(this)) >=
                amountToReceiver,
              'Balance under amount to transfer'
            );

            IERC20Upgradeable(asset).transfer(receiver, amountToReceiver);
            IERC20Upgradeable(asset).transfer(
              address(baluniRouter),
              amountToRouter
            );
            IERC20Upgradeable(asset).transfer(treasury, amountToTreasury);
          } else {
            require(
              IERC20Upgradeable(USDC).balanceOf(address(this)) >=
                rebBuyQty / 1e12,
              'Balance under RebuyQty'
            );
            uint256 multiHopSwapResult = _multiHopSwap(
              address(USDC),
              address(WNATIVE),
              address(assets[underweightVaults[i]]),
              rebBuyQty / 1e12,
              address(this)
            );

            uint256 amountToReceiver = calculateNetAmountAfterFee(
              multiHopSwapResult
            );
            uint256 remainingToReceiver = multiHopSwapResult - amountToReceiver;
            uint256 amountToRouter = calculateNetAmountAfterFee(
              remainingToReceiver
            );
            uint256 amountToTreasury = remainingToReceiver - amountToRouter;

            require(
              IERC20Upgradeable(asset).balanceOf(address(this)) >=
                amountToReceiver,
              'Balance under amountToTransfer'
            );

            IERC20Upgradeable(asset).transfer(receiver, amountToReceiver);
            IERC20Upgradeable(asset).transfer(
              address(baluniRouter),
              amountToRouter
            );
            IERC20Upgradeable(asset).transfer(treasury, amountToTreasury);
          }
        }
      }
    }
  }

  /**
   * @dev Returns the valuation of a given amount of a token.
   * @param amount The amount of the token.
   * @param token The address of the token.
   * @return The valuation of the token amount.
   */
  function getTokenValuation(
    uint256 amount,
    address token
  ) internal view returns (uint256) {
    return baluniRouter.tokenValuation(amount, token);
  }

  /**
   * @dev Rebalances the assets in the contract based on the specified weights.
   * @param assets An array of asset addresses.
   * @param weights An array of weights corresponding to the assets.
   * @param receiver The address that will receive the rebalanced assets.
   * @return A boolean indicating the success of the rebalance operation.
   */
  function rebalance(
    address[] memory assets,
    uint256[] memory weights,
    address sender,
    address receiver
  ) external override returns (bool) {
    uint256 totalValue = calculateTotalValue(assets, sender);
    adjustWeights(assets, weights, totalValue, sender, receiver);
    return true;
  }

  /**
   * @dev Checks if rebalancing is required based on the asset weights and limit.
   * @param assets The array of asset addresses.
   * @param weights The array of target weights for each asset.
   * @param limit The maximum percentage difference allowed between the current weight and target weight.
   * @param sender The address of the account holding the assets.
   * @return A boolean indicating whether rebalancing is required.
   */
  function checkRebalance(
    address[] memory assets,
    uint256[] memory weights,
    uint256 limit,
    address sender
  ) external view override returns (RebalanceType) {
    require(
      IERC20Upgradeable(address(baluniRouter)).balanceOf(sender) >= 1 ether,
      'You need to hold at least 1 BALUNI'
    );
    uint256 len = assets.length;

    uint256 totalValue = calculateTotalValue(assets, sender);
    bool overweight;

    uint256 overweightVaultsLength;
    uint256 underweightVaultsLength;
    uint256 overweightAmount;
    uint256 overweightPercent;
    uint256 targetWeight;
    uint256 currentWeight;
    uint256 totalActiveWeight;
    uint256 finalUsdBalance;

    uint256[] memory overweightVaults = new uint256[](len * 2);
    uint256[] memory overweightAmounts = new uint256[](len * 2);
    uint256[] memory underweightVaults = new uint256[](len * 2);
    uint256[] memory underweightAmounts = new uint256[](len * 2);

    for (uint256 i = 0; i < len; i++) {
      uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(sender);
      uint256 decimals = IERC20MetadataUpgradeable(assets[i]).decimals();
      uint256 totalTokensValuation;

      if (assets[i] == address(USDC)) {
        totalTokensValuation = balance * 1e12;
      } else {
        totalTokensValuation = getTokenValuation(balance, assets[i]);
      }

      targetWeight = weights[i];
      currentWeight = (totalTokensValuation * (10000)) / (totalValue);
      overweight = currentWeight > targetWeight;
      overweightPercent = overweight
        ? currentWeight - (targetWeight)
        : targetWeight - (currentWeight);

      uint256 price = baluniRouter.tokenValuation(
        1 * 10 ** decimals,
        assets[i]
      );

      uint256 _limit = limit;

      if (overweight && overweightPercent > _limit) {
        overweightAmount = (overweightPercent * (totalValue)) / (10000);
        finalUsdBalance += overweightAmount;

        overweightAmount = (overweightAmount * (1e18)) / (price);
        if (decimals != uint8(18)) {
          overweightAmount = overweightAmount / (10 ** (18 - decimals));
        }
        overweightVaults[overweightVaultsLength] = i;
        overweightAmounts[overweightVaultsLength] = overweightAmount;
        overweightVaultsLength++;
      } else if (!overweight && overweightPercent > _limit) {
        totalActiveWeight += overweightPercent;
        overweightAmount = overweightPercent;
        // overweightAmount = overweightPercent.mul(totalValue).div(10000);
        underweightVaults[underweightVaultsLength] = i;
        underweightAmounts[underweightVaultsLength] = overweightAmount;
        underweightVaultsLength++;
      }
    }

    overweightVaults = _resize(overweightVaults, overweightVaultsLength);
    overweightAmounts = _resize(overweightAmounts, overweightVaultsLength);
    underweightVaults = _resize(underweightVaults, underweightVaultsLength);
    underweightAmounts = _resize(underweightAmounts, underweightVaultsLength);

    if (overweightVaultsLength > 0) {
      return RebalanceType.Overweight;
    } else if (underweightVaultsLength > 0) {
      return RebalanceType.Underweight;
    } else {
      return RebalanceType.NoRebalance;
    }
  }

  /**
   * @dev Resizes an array to a specified size.
   * @param arr The original array to be resized.
   * @param size The new size for the array.
   * @return ret The resized array.
   */
  function _resize(
    uint256[] memory arr,
    uint256 size
  ) internal pure returns (uint256[] memory) {
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
  function secureApproval(
    address token,
    address spender,
    uint256 amount
  ) internal {
    IERC20Upgradeable _token = IERC20Upgradeable(token);
    _token.approve(spender, amount);
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
    require(
      IERC20Upgradeable(token0).balanceOf(msg.sender) >= amount,
      'Insufficient Balance'
    );
    IERC20Upgradeable(token0).transferFrom(msg.sender, address(this), amount);
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
    require(
      IERC20Upgradeable(token0).balanceOf(msg.sender) >= amount,
      'Insufficient Balance'
    );
    IERC20Upgradeable(token0).transferFrom(msg.sender, address(this), amount);
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
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
      .ExactInputSingleParams({
        tokenIn: token0,
        tokenOut: token1,
        fee: 3000,
        recipient: address(receiver),
        deadline: block.timestamp + 300, // Adding a 5-minute buffer
        amountIn: tokenBalance,
        amountOutMinimum: 0,
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
      path: abi.encodePacked(
        token0,
        uint24(3000),
        token1,
        uint24(3000),
        token2
      ),
      recipient: address(receiver),
      deadline: block.timestamp + 300, // Adding a 5-minute buffer
      amountIn: tokenBalance,
      amountOutMinimum: 0
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
  function calculateNetAmountAfterFee(
    uint256 _amount
  ) internal view returns (uint256) {
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
  function calculateTotalValue(
    address[] memory assets,
    address user
  ) private view returns (uint256) {
    uint256 _tokenValue = 0;
    for (uint256 i = 0; i < assets.length; i++) {
      uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(user);

      if (assets[i] == address(USDC)) {
        _tokenValue += balance * 1e12;
      } else {
        _tokenValue += getTokenValuation(balance, assets[i]);
      }
    }

    return _tokenValue;
  }
}
