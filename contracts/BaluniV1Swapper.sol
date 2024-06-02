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

import './interfaces/IBaluniV1PoolPeriphery.sol';
import './interfaces/IBaluniV1PoolFactory.sol';
import './interfaces/IBaluniV1Registry.sol';

contract BaluniV1Swapper is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IBaluniV1Registry public registry;

    function initialize(address _registry) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        registry = IBaluniV1Registry(_registry);
    }

    function reinitialize(address _registry, uint64 version) public reinitializer(version) {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        registry = IBaluniV1Registry(_registry);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

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
        uint256 allowance = IERC20(token0).allowance(msg.sender, address(this));
        require(allowance >= amount, 'BaluniSwapper: Insufficient Allowance');
        IERC20(token0).transferFrom(msg.sender, address(this), amount);
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
        uint256 allowance = IERC20(token0).allowance(msg.sender, address(this));
        require(allowance >= amount, 'BaluniSwapper: Insufficient Allowance');
        IERC20(token0).transferFrom(msg.sender, address(this), amount);
        return _multiHopSwap(token0, token1, token2, amount, receiver);
    }

    /**
     * @dev Executes a single swap on Uniswap.
     * @param token0 The address of the input token.
     * @param token1 The address of the output token.
     * @param amount The amount of input token to be swapped.
     * @param receiver The address that will receive the swapped tokens.
     * @return amountOut The amount of output tokens received.
     */
    function _singleSwap(
        address token0,
        address token1,
        uint256 amount,
        address receiver
    ) internal returns (uint256 amountOut) {
        address baluniPeriphery = registry.getBaluniPoolPeriphery();
        address uniswapRouter = registry.getUniswapRouter();

        IBaluniV1PoolPeriphery periphery = IBaluniV1PoolPeriphery(baluniPeriphery);

        _secureApproval(token0, baluniPeriphery, amount);

        try periphery.swap(token0, token1, amount, receiver) returns (uint256 amountReceived) {
            if (amountReceived > 0) {
                return amountReceived;
            }
        } catch {
            _secureApproval(token0, uniswapRouter, amount);

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: token0,
                tokenOut: token1,
                fee: 3000,
                recipient: address(receiver),
                deadline: block.timestamp,
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

            return ISwapRouter(uniswapRouter).exactInputSingle(params);
        }
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
    ) internal returns (uint256 amountOut) {
        address baluniPeriphery = registry.getBaluniPoolPeriphery();
        IBaluniV1PoolPeriphery periphery = IBaluniV1PoolPeriphery(baluniPeriphery);
        uint256 intermediateBalance;
        _secureApproval(token0, baluniPeriphery, tokenBalance);

        try periphery.swap(token0, token1, tokenBalance, address(this)) returns (uint256 amountReceived) {
            if (amountReceived > 0) {
                intermediateBalance = amountReceived;
            } else {
                return _multiHopSwapFallback(token0, token1, token2, tokenBalance, receiver);
            }
        } catch {
            return _multiHopSwapFallback(token0, token1, token2, tokenBalance, receiver);
        }

        try periphery.swap(token1, token2, intermediateBalance, receiver) returns (uint256 amountReceived) {
            if (amountReceived > 0) {
                return amountReceived;
            } else {
                return _multiHopSwapFallback(token0, token1, token2, tokenBalance, receiver);
            }
        } catch {
            return _multiHopSwapFallback(token0, token1, token2, tokenBalance, receiver);
        }
    }

    function _multiHopSwapFallback(
        address token0,
        address token1,
        address token2,
        uint256 tokenBalance,
        address receiver
    ) internal returns (uint256 amountOut) {
        address uniswapRouter = registry.getUniswapRouter();
        _secureApproval(token0, uniswapRouter, tokenBalance);

        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: abi.encodePacked(token0, uint24(3000), token1, uint24(3000), token2),
            recipient: address(receiver),
            deadline: block.timestamp,
            amountIn: tokenBalance,
            amountOutMinimum: 0
        });
        return ISwapRouter(uniswapRouter).exactInput(params);
    }

    /**
     * @dev Ensures that the contract has the necessary approval for a token to be spent by a spender.
     * If the current allowance is not equal to the desired amount, it updates the allowance accordingly.
     * @param token The address of the token to be approved.
     * @param spender The address of the spender.
     * @param amount The desired allowance amount.
     * @notice This function is internal and should not be called directly.
     */
    function _secureApproval(address token, address spender, uint256 amount) internal {
        IERC20 _token = IERC20(token);
        // check allowance thena pprove
        if (_token.allowance(address(this), spender) < amount) {
            _token.approve(spender, 0);
            _token.approve(spender, amount);
        }
    }
}
