// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

/**
 * @title IBaluniV1PoolPeriphery
 * @dev Interface for the BaluniV1PoolPeriphery contract
 */
interface IBaluniV1PoolPeriphery {
    function initialize(address _registry) external;

    function reinitialize(address _registry, uint64 version) external;

    function swapTokenForToken(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minAmount,
        address from,
        address to,
        uint deadline
    ) external returns (uint256 amountOut, uint256 haircut);

    function swapTokensForTokens(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut, uint256 haircut);

    function batchSwap(
        address[] calldata fromTokens,
        address[] calldata toTokens,
        uint256[] calldata amounts,
        address[] calldata receivers
    ) external returns (uint256[] memory);

    function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256);

    function getPoolsContainingToken(address token) external view returns (address[] memory);

    function getVersion() external view returns (uint64);
}
