// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1Rebalancer {
  enum RebalanceType {
    Overweight,
    Underweight,
    NoRebalance
  }

  function checkRebalance(
    address[] memory assets,
    uint256[] memory weights,
    uint256 limit,
    address sender
  ) external view returns (RebalanceType);

  function rebalance(
    address[] memory assets,
    uint256[] memory weights,
    address sender,
    address receiver
  ) external returns (bool);
}
