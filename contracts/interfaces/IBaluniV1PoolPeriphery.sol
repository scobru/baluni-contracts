// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1PoolPeriphery {
    function getReserves(address pool) external view returns (uint256[] memory);

    function getAssetReserve(address pool, address asset) external view returns (uint256);
}
