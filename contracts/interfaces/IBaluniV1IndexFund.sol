// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

/**
 * @title IBaluniV1IndexFund
 * @dev Interface for the BaluniV1IndexFund contract - A tokenized index fund
 */
interface IBaluniV1IndexFund {
    struct AssetInfo {
        address asset;
        uint256 weight;
        uint256 reserve;
    }

    event WeightsRebalanced(address indexed user, uint256[] amountsToAdd);
    event Withdraw(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event DepositSingle(address indexed user, address token, uint256 amount, uint256 shares);
    event RebalancePerformed(address indexed user, address[] assets);
    event WeightsUpdated(uint256[] newWeights);

    function rebalanceAndDeposit(address receiver) external returns (uint256[] memory);

    function getTokenWeight(address token) external view returns (uint256);

    function deposit(address to, uint256[] memory amounts, uint256 deadline) external returns (uint256);

    function depositSingle(address token, uint256 amount, address to, uint256 deadline) external returns (uint256);

    function withdraw(uint256 share, address to, uint256 deadline) external returns (uint256);

    function rebalance() external;

    function setWeights(uint256[] memory newWeights) external;

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
