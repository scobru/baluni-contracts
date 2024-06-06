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

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';

import '../interfaces/IBaluniV1PoolRegistry.sol';
import '../interfaces/IBaluniV1PoolPeriphery.sol';
import '../interfaces/IBaluniV1Registry.sol';
import '../interfaces/IBaluniV1Pool.sol';

/**
 * @title BaluniV1PoolPeriphery
 * @dev This contract serves as the periphery contract for interacting with BaluniV1Pool contracts.
 * It provides functions for swapping tokens, adding liquidity, removing liquidity, and getting the amount out for a given swap.
 */
contract BaluniV1PoolPeriphery is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    IBaluniV1PoolPeriphery
{
    IBaluniV1Registry public registry;

    mapping(address => mapping(address => uint256)) public poolsReserves; // Mapping of token address to pool addresses (for quick lookup

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

    function initialize(address _registry) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(msg.sender);
        registry = IBaluniV1Registry(_registry);
    }

    function reinitialize(address _registry, uint64 version) public reinitializer(version) {
        registry = IBaluniV1Registry(_registry);
    }

    /**
     * @dev Internal function to authorize an upgrade to a new implementation contract.
     * @param newImplementation The address of the new implementation contract.
     * @notice This function can only be called by the contract owner.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function swapTokenForToken(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minAmount,
        address from,
        address to,
        uint deadline
    ) public override ensure(deadline) nonReentrant returns (uint256 amountOut, uint256 haircut) {
        IBaluniV1PoolRegistry poolRegistry = IBaluniV1PoolRegistry(registry.getBaluniPoolRegistry());
        require(fromAmount > 0, 'Amount must be greater than zero');
        address poolAddress = poolRegistry.getPoolByAssets(fromToken, toToken);
        require(poolAddress != address(0), 'BaluniV1PoolPeriphery: Pool not found');
        IERC20(fromToken).transferFrom(from, address(this), fromAmount);

        address[] memory tokenPath = new address[](2);
        tokenPath[0] = fromToken;
        tokenPath[1] = toToken;

        address[] memory poolPath = new address[](1);
        poolPath[0] = poolAddress;

        (amountOut, haircut) = _swap(tokenPath, poolPath, fromAmount, to);
        require(amountOut >= minAmount, 'amountOut too low');

        return (amountOut, haircut);
    }

    function swapTokensForTokens(
        address[] memory tokenPath,
        address[] memory poolPath,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external override ensure(deadline) nonReentrant returns (uint256 amountOut, uint256 haircut) {
        require(fromAmount > 0, 'invalid from amount');
        require(tokenPath.length >= 2, 'invalid token path');
        require(poolPath.length == tokenPath.length - 1, 'invalid pool path');
        require(to != address(0), 'zero address');

        // get from token from users
        IERC20(tokenPath[0]).transferFrom(address(msg.sender), address(this), fromAmount);

        (amountOut, haircut) = _swap(tokenPath, poolPath, fromAmount, to);
        require(amountOut >= minimumToAmount, 'amountOut too low');
    }

    /// @notice _swap private function. Assumes router has initial fromAmount in balance.
    /// @dev assumes tokens being swapped have been approve via the approveSpendingByPool function
    /// @param tokenPath An array of token addresses. path.length must be >= 2.
    /// @param tokenPath The first element of the path is the input token, the last element is the output token.
    /// @param poolPath An array of pool addresses. The pools where the pathTokens are contained in order.
    /// @param fromAmount the amount in
    /// @param to the user to send the tokens to
    /// @return amountOut received by user
    /// @return haircut total fee charged by pool
    function _swap(
        address[] memory tokenPath,
        address[] memory poolPath,
        uint256 fromAmount,
        address to
    ) internal returns (uint256 amountOut, uint256 haircut) {
        // haircut of current call
        uint256 localHaircut;
        // next from amount, starts with fromAmount in arg
        uint256 nextFromAmount = fromAmount;
        // where to send tokens on next step
        address nextTo;

        for (uint256 i; i < poolPath.length; ++i) {
            // check if we're reaching the beginning or end of the poolPath array
            if (i == 0 && poolPath.length == 1) {
                // only one element in pool path - simple swap
                nextTo = to;
            } else if (i == 0) {
                // first element of a larger than one poolPath
                nextTo = address(this);
            } else if (i < poolPath.length - 1) {
                // middle element of a larger than one poolPath
                nextTo = address(this);
                nextFromAmount = amountOut;
            } else {
                // send final swapped tokens to user
                nextTo = to;
                nextFromAmount = amountOut;
            }

            uint256 allowance = IERC20(tokenPath[i]).allowance(address(this), poolPath[i]);

            if (nextFromAmount >= allowance) {
                IERC20(tokenPath[i]).approve(poolPath[i], nextFromAmount);
            }

            // make the swap with the correct arguments
            (amountOut, localHaircut) = IBaluniV1Pool(poolPath[i]).swap(
                tokenPath[i],
                tokenPath[i + 1],
                nextFromAmount,
                0, // minimum amount received is ensured on calling function
                nextTo,
                type(uint256).max // deadline is ensured on calling function
            );
            // increment total haircut
            haircut += localHaircut * 10 ** (18 - IERC20Metadata(tokenPath[i + 1]).decimals());
        }
    }

    /**
     * @notice Quotes potential outcome of a swap given current tokenPath and poolPath,
     taking in account slippage and haircut
     * @dev To be used by frontend
     * @param tokenPath The token swap path
     * @param poolPath The token pool path
     * @param fromAmount The amount to quote
     * @return potentialOutcome The potential final amount user would receive
     * @return haircut The total haircut that would be applied
     */
    function quotePotentialSwaps(
        address[] memory tokenPath,
        address[] memory poolPath,
        uint256 fromAmount
    ) external view returns (uint256 potentialOutcome, uint256 haircut) {
        require(fromAmount > 0, 'invalid from amount');
        require(tokenPath.length >= 2, 'invalid token path');
        require(poolPath.length == tokenPath.length - 1, 'invalid pool path');

        // haircut of current call
        uint256 localHaircut;
        // next from amount, starts with fromAmount in arg
        uint256 nextFromAmount = fromAmount;
        // where to send tokens on next step

        for (uint256 i; i < poolPath.length; ++i) {
            // check if we're reaching the beginning or end of the poolPath array
            if (i != 0) {
                nextFromAmount = potentialOutcome;
            }

            // make the swap with the correct arguments
            (potentialOutcome) = IBaluniV1Pool(poolPath[i]).quotePotentialSwap(
                tokenPath[i],
                tokenPath[i + 1],
                nextFromAmount
            );

            // increment total haircut - convert to 18 d.p decimals
            haircut += localHaircut * 10 ** (18 - IERC20Metadata(tokenPath[i + 1]).decimals());
        }

        return (potentialOutcome, haircut);
    }

    /**
     * @dev Performs batch swaps between multiple token pairs.
     * @param fromTokens An array of addresses representing the tokens to swap from.
     * @param toTokens An array of addresses representing the tokens to swap to.
     * @param amounts An array of amounts representing the amounts to swap.
     * @param receivers An array of addresses representing the receivers of the swapped tokens.
     * @return An array of amounts representing the amounts of tokens received after the swaps.
     */
    function batchSwap(
        address[] calldata fromTokens,
        address[] calldata toTokens,
        uint256[] calldata amounts,
        address[] calldata receivers
    ) external override returns (uint256[] memory) {
        require(
            fromTokens.length == toTokens.length &&
                toTokens.length == amounts.length &&
                amounts.length == receivers.length,
            'Input arrays length mismatch'
        );

        uint256[] memory amountsOut = new uint256[](fromTokens.length);

        for (uint256 i = 0; i < fromTokens.length; i++) {
            require(amounts[i] > 0, 'Amount must be greater than zero');

            address fromToken = fromTokens[i];
            address toToken = toTokens[i];

            uint256 amount = amounts[i];
            address receiver = receivers[i];

            require(IERC20(fromToken).balanceOf(msg.sender) >= amount, 'Insufficient Balance');
            (amountsOut[i], ) = swapTokenForToken(
                fromToken,
                toToken,
                amount,
                0,
                msg.sender,
                receiver,
                block.timestamp + 300
            );
        }

        return amountsOut;
    }

    /**
     * @dev Gets the amount of tokens received after a swap in a BaluniV1Pool.
     * @param fromToken The address of the token to swap from.
     * @param toToken The address of the token to swap to.
     * @param amount The amount of tokens to swap.
     * @return The amount of tokens received after the swap.
     */
    function getAmountOut(address fromToken, address toToken, uint256 amount) external view override returns (uint256) {
        IBaluniV1PoolRegistry poolRegistry = IBaluniV1PoolRegistry(registry.getBaluniPoolRegistry());
        address poolAddress = poolRegistry.getPoolByAssets(fromToken, toToken);
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
        uint256 amountOut = pool.quotePotentialSwap(fromToken, toToken, amount);
        return amountOut;
    }

    /**
     * @dev Returns an array of pool addresses that contain the given token.
     * @param token The address of the token to search for.
     * @return An array of pool addresses.
     */
    function getPoolsContainingToken(address token) external view override returns (address[] memory) {
        IBaluniV1PoolRegistry poolRegistry = IBaluniV1PoolRegistry(registry.getBaluniPoolRegistry());
        return poolRegistry.getPoolsByAsset(token);
    }

    /**
     * @dev Returns the version of the contract.
     * @return The version string.
     */
    function getVersion() external view override returns (uint64) {
        return _getInitializedVersion();
    }
}
