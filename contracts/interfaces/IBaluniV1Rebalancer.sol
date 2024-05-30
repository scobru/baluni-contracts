// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1Rebalancer {
    struct RebalanceVars {
        uint256 length;
        uint256 totalValue;
        uint256 finalUsdBalance;
        uint256 overweightVaultsLength;
        uint256 underweightVaultsLength;
        uint256 totalActiveWeight;
        uint256 amountOut;
        uint256[] overweightVaults;
        uint256[] overweightAmounts;
        uint256[] underweightVaults;
        uint256[] underweightAmounts;
        uint256[] balances;
    }

    // Variables
    function baluniRouter() external view returns (address);

    function USDC() external view returns (address);

    function WNATIVE() external view returns (address);

    function _1InchSpotAgg() external view returns (address);

    function treasury() external view returns (address);

    // Functions
    function rebalance(
        uint256[] memory balances,
        address[] calldata assets,
        uint256[] calldata weights,
        uint256 limit,
        address sender,
        address receiver,
        address baseAsset
    ) external;

    function checkRebalance(
        uint256[] memory balances,
        address[] calldata assets,
        uint256[] calldata weights,
        uint256 limit,
        address sender,
        address baseAsset
    ) external view returns (RebalanceVars memory);

    function convert(address fromToken, address toToken, uint256 amount) external view returns (uint256);
}
