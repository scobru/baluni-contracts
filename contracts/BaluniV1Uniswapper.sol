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
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

abstract contract BaluniV1Uniswapper {
  ISwapRouter public uniswapRouter;
  IUniswapV3Factory public uniswapFactory;

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
  ) private returns (uint256 amountOut) {
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
      tokenIn: token0,
      tokenOut: token1,
      fee: 3000,
      recipient: address(receiver),
      deadline: block.timestamp,
      amountIn: tokenBalance,
      amountOutMinimum: 0,
      sqrtPriceLimitX96: 0
    });

    return uniswapRouter.exactInputSingle(params);
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
  ) private returns (uint256 amountOut) {
    ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
      path: abi.encodePacked(token0, uint24(3000), token1, uint24(3000), token2),
      recipient: address(receiver),
      deadline: block.timestamp,
      amountIn: tokenBalance,
      amountOutMinimum: 0
    });
    return uniswapRouter.exactInput(params);
  }
}
