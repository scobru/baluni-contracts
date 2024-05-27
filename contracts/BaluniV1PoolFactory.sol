// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import './BaluniV1Pool.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

contract BaluniV1PoolFactory is Initializable, UUPSUpgradeable, OwnableUpgradeable {
  address[] public allPools;
  mapping(address => mapping(address => address)) public getPool;

  address public rebalancer;
  address public periphery;

  event PoolCreated(address indexed pool, address[] assets, address rebalancer);

  function initialize(address _rebalancer) public initializer {
    __UUPSUpgradeable_init();
    __Ownable_init(msg.sender);
    rebalancer = _rebalancer;
  }

  function reinitialize(address _rebalancer, uint64 _version) public reinitializer(_version) {
    rebalancer = _rebalancer;
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  function createPool(address[] memory assets, uint256[] memory weights, uint256 trigger) external returns (address) {
    require(periphery != address(0), 'Router not set');
    require(assets.length > 1, 'At least two assets are required');
    require(assets.length == weights.length, 'Assets and weights length mismatch');

    for (uint256 i = 0; i < assets.length; i++) {
      for (uint256 j = i + 1; j < assets.length; j++) {
        require(address(getPool[assets[i]][assets[j]]) == address(0), 'Pool already exists for this pair');
      }
    }

    BaluniV1Pool newPool = new BaluniV1Pool(rebalancer, assets, weights, trigger, periphery);

    address poolAddress = address(newPool);

    allPools.push(poolAddress);
    for (uint256 i = 0; i < assets.length; i++) {
      for (uint256 j = i + 1; j < assets.length; j++) {
        getPool[assets[i]][assets[j]] = poolAddress;
        getPool[assets[j]][assets[i]] = poolAddress;
      }
    }

    emit PoolCreated(poolAddress, assets, rebalancer);

    return poolAddress;
  }

  function getAllPools() external view returns (address[] memory) {
    return allPools;
  }

  function getPoolsCount() external view returns (uint256) {
    return allPools.length;
  }

  function getPoolAssets(address poolAddress) external view returns (address[] memory) {
    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    return pool.getAssets();
  }

  function getPoolByAssets(address asset1, address asset2) external view returns (address) {
    return address(getPool[asset1][asset2]);
  }

  function getPoolsByAsset(address token) external view returns (address[] memory) {
    address[] memory pools = new address[](allPools.length);
    uint256 count = 0;

    for (uint256 i = 0; i < allPools.length; i++) {
      BaluniV1Pool pool = BaluniV1Pool(allPools[i]);
      address[] memory assets = pool.getAssets();

      for (uint256 j = 0; j < assets.length; j++) {
        if (assets[j] == token) {
          pools[count] = address(pool);
          count++;
          break;
        }
      }

      if (count == pools.length) {
        break;
      }
    }

    address[] memory result = new address[](count);
    for (uint256 i = 0; i < count; i++) {
      result[i] = pools[i];
    }

    return result;
  }

  function changePeriphery(address _newPeriphery) external onlyOwner {
    periphery = _newPeriphery;
  }
}
