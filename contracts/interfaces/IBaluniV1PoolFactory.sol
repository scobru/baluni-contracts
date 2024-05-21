// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1PoolFactory {
  function getPoolByAssets(address asset1, address asset2) external view returns (address);
}
