// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

/**
 * @title IBaluniV1Pool
 * @dev Interface for the BaluniV1Pool contract
 */
interface IBaluniV1Pool {
    struct AssetInfo {
        address asset;
        uint256 weight;
        uint256 slippage;
        uint256 reserve;
    }

    event WeightsRebalanced(address indexed user, uint256[] amountsToAdd);
    event Swap(address indexed user, address fromToken, address toToken, uint256 amountIn, uint256 amountOut);
    event Withdraw(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event RebalancePerformed(address indexed user, address[] assets);

    function rebalanceAndDeposit(address receiver) external returns (uint256[] memory);

    function swap(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minAmount,
        address receiver,
        uint256 deadline
    ) external returns (uint256 amountOut, uint256 fee);

    function quotePotentialSwap(address fromToken, address toToken, uint256 amount) external view returns (uint256);

    function getSlippage(address token) external view returns (uint256);

    function getTokenWeight(address token) external view returns (uint256);

    function getDeviationForToken(address token) external view returns (uint256);

    function getSlippageParams() external view returns (uint256[] memory);

    function deposit(address to, uint256[] memory amounts, uint256 deadline) external returns (uint256);

    function withdraw(uint256 share, address to, uint256 deadline) external returns (uint256);

    function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256);

    function rebalance() external;

    function getDeviations() external view returns (bool[] memory directions, uint256[] memory deviations);

    function assetLiquidity(uint256 assetIndex) external view returns (uint256);

    function totalValuation() external view returns (uint256 totalVal, uint256[] memory valuations);

    function liquidity() external view returns (uint256);

    function unitPrice() external view returns (uint256);

    function getReserves() external view returns (uint256[] memory);

    function getAssetReserve(address asset) external view returns (uint256);

    function getAssets() external view returns (address[] memory);

    function getWeights() external view returns (uint256[] memory);

    function isRebalanceNeeded() external view returns (bool);
}
