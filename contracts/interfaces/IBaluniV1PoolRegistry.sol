// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1PoolRegistry {
    function getPoolByAssets(address asset1, address asset2) external view returns (address);
    function getPoolsByAsset(address token) external view returns (address[] memory);
    function poolExist(address _pool) external view returns (bool);
    function getAllPools() external view returns (address[] memory);
}
