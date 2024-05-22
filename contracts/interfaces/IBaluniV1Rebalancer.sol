// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1Rebalancer {
  enum RebalanceType {
    Overweight,
    Underweight,
    NoRebalance
  }

  struct RebalanceVars {
    uint256 len;
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

  function checkRebalance(
    address[] calldata assets,
    uint256[] calldata weights,
    uint256 limit,
    address sender
  ) external view returns (RebalanceVars memory);

  function rebalance(
    address[] calldata assets,
    uint256[] calldata weights,
    address sender,
    address receiver,
    uint256 limit
  ) external;

  function getBaluniRouter() external view returns (address);
}
