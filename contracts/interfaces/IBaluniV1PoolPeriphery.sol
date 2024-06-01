// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

/**
 * @title IBaluniV1PoolPeriphery
 * @dev Interface for the BaluniV1PoolPeriphery contract.
 */
interface IBaluniV1PoolPeriphery {
    /**
     * @dev Swaps tokens in a BaluniV1Pool.
     * @param fromToken The address of the token to swap from.
     * @param toToken The address of the token to swap to.
     * @param amount The amount of tokens to swap.
     * @param receiver The address of the receiver.
     * @return The amount of tokens received after the swap.
     */
    function swap(address fromToken, address toToken, uint256 amount, address receiver) external returns (uint256);

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
    ) external returns (uint256[] memory);

    /**
     * @dev Rebalances weights in a pool.
     * @param poolAddress The address of the pool.
     * @param receiver The address of the receiver.
     */
    function rebalanceWeights(address poolAddress, address receiver) external;

    /**
     * @dev Adds liquidity to a BaluniV1Pool.
     * @param amounts An array of amounts for each asset to add as liquidity.
     * @param poolAddress The address of the pool.
     * @param receiver The address of the receiver.
     */
    function addLiquidity(uint256[] memory amounts, address poolAddress, address receiver) external returns (uint256);

    /**
     * @dev Removes liquidity from a BaluniV1Pool.
     * @param share The amount of liquidity tokens to remove.
     * @param poolAddress The address of the pool.
     * @param receiver The address of the receiver.
     */
    function removeLiquidity(uint256 share, address poolAddress, address receiver) external;

    /**
     * @dev Gets the amount of tokens received after a swap in a BaluniV1Pool.
     * @param fromToken The address of the token to swap from.
     * @param toToken The address of the token to swap to.
     * @param amount The amount of tokens to swap.
     * @return The amount of tokens received after the swap.
     */
    function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256);

    /**
     * @dev Performs rebalance if needed for the given tokens.
     * @param poolAddress The address of the token pool to rebalance.
     */
    function performRebalanceIfNeeded(address poolAddress) external;

    /**
     * @dev Returns an array of pool addresses that contain the given token.
     * @param token The address of the token to search for.
     * @return An array of pool addresses.
     */
    function getPoolsContainingToken(address token) external view returns (address[] memory);

    /**
     * @dev Returns the version of the contract.
     * @return The version string.
     */
    function getVersion() external view returns (uint64);

    /**
     * @dev Returns the reserves of the pool.
     * @param pool The address of the pool.
     * @return An array of reserves.
     */
    function getReserves(address pool) external view returns (uint256[] memory);

    /**
     * @dev Returns the reserve of a specific asset in a pool.
     * @param pool The address of the pool.
     * @param asset The address of the asset.
     * @return The reserve of the asset.
     */
    function getAssetReserve(address pool, address asset) external view returns (uint256);
}
