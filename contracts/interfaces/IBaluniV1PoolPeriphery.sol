// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1PoolPeriphery {
  function moveAll() external;

  function moveAsset(address asset, address to, uint256 amount) external;
}
