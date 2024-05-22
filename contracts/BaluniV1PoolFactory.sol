// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;
/**
 *  __                  __                      __
 * /  |                /  |                    /  |
 * $$ |____    ______  $$ | __    __  _______  $$/
 * $$      \  /      \ $$ |/  |  /  |/       \ /  |
 * $$$$$$$  | $$$$$$  |$$ |$$ |  $$ |$$$$$$$  |$$ |
 * $$ |  $$ | /    $$ |$$ |$$ |  $$ |$$ |  $$ |$$ |
 * $$ |__$$ |/$$$$$$$ |$$ |$$ \__$$ |$$ |  $$ |$$ |
 * $$    $$/ $$    $$ |$$ |$$    $$/ $$ |  $$ |$$ |
 * $$$$$$$/   $$$$$$$/ $$/  $$$$$$/  $$/   $$/ $$/
 *
 *
 *                  ,-""""-.
 *                ,'      _ `.
 *               /       )_)  \
 *              :              :
 *              \              /
 *               \            /
 *                `.        ,'
 *                  `.    ,'
 *                    `.,'
 *                     /\`.   ,-._
 *                         `-'    \__
 *                              .
 *               s                \
 *                                \\
 *                                 \\
 *                                  >\/7
 *                              _.-(6'  \
 *                             (=___._/` \
 *                                  )  \ |
 *                                 /   / |
 *                                /    > /
 *                               j    < _\
 *                           _.-' :      ``.
 *                           \ r=._\        `.
 */

import './BaluniV1Pool.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

import './interfaces/IBaluniV1Pool.sol';

contract BaluniV1PoolFactory is Initializable, UUPSUpgradeable, OwnableUpgradeable {
  // Array to keep track of all pools created
  BaluniV1Pool[] public allPools;

  // Mapping to keep track of all pools for a specific pair of assets
  mapping(address => mapping(address => BaluniV1Pool)) public getPool;

  // Event to emit when a new pool is created
  event PoolCreated(
    address indexed pool,
    address indexed asset1,
    address indexed asset2,
    address oracle,
    address rebalancer
  );

  /**
   * @dev Initializes the contract.
   * It calls the initializers of the parent contracts.
   */
  function initialize() public initializer {
    __UUPSUpgradeable_init();
    __Ownable_init(msg.sender);
  }

  /**
   * @dev Reinitializes the contract with a specific version.
   * It calls the initializers of the parent contracts.
   * @param version The version to be set.
   */
  function reinitialize(uint64 version) public reinitializer(version) {
    __UUPSUpgradeable_init();
    __Ownable_init(msg.sender);
  }

  /**
   * @dev Internal function to authorize an upgrade to a new implementation contract.
   * @param newImplementation The address of the new implementation contract.
   * @notice This function can only be called by the contract owner.
   */
  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  /**
   * @dev Creates a new pool with the specified parameters.
   * @param _aggregatorV3Interface The address of the oracle contract.
   * @param rebalancer The address of the rebalancer contract.
   * @param assets The addresses of the assets.
   * @param weights The weights of the assets.
   * @param trigger The trigger value for rebalancing.
   * @return The address of the newly created pool.
   */
  function createPool(
    address _aggregatorV3Interface,
    address rebalancer,
    address[] memory assets,
    uint256[] memory weights,
    uint256 trigger
  ) external onlyOwner returns (address) {
    address asset1 = assets[0];
    address asset2 = assets[1];
    require(_aggregatorV3Interface != address(0), 'Oracle address cannot be zero');
    require(rebalancer != address(0), 'Rebalancer address cannot be zero');
    require(asset1 != address(0) && asset2 != address(0), 'Asset addresses cannot be zero');
    require(asset1 != asset2, 'Assets cannot be the same');

    // Check if a pool already exists for this pair of assets
    require(address(getPool[asset1][asset2]) == address(0), 'Pool already exists for this pair');

    // Create a new pool instance
    BaluniV1Pool newPool = new BaluniV1Pool(_aggregatorV3Interface, rebalancer, assets, weights, trigger);

    // Update the pool tracking
    allPools.push(newPool);
    getPool[asset1][asset2] = newPool;
    getPool[asset2][asset1] = newPool; // To ensure both asset1-asset2 and asset2-asset1 point to the same pool

    emit PoolCreated(address(newPool), asset1, asset2, _aggregatorV3Interface, rebalancer);

    return address(newPool);
  }

  /**
   * @dev Returns an array of all pools created by the factory.
   * @return An array of BaluniV1Pool instances.
   */
  function getAllPools() external view returns (BaluniV1Pool[] memory) {
    return allPools;
  }

  /**
   * @dev Returns the total number of pools created by the factory.
   * @return The number of pools.
   */
  function getPoolsCount() external view returns (uint256) {
    return allPools.length;
  }

  /**
   * @dev Retrieves the assets of a pool.
   * @param poolAddress The address of the pool.
   * @return The addresses of the assets in the pool.
   */
  function getPoolAssets(address poolAddress) external view returns (address, address) {
    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    return (address(pool.asset1()), address(pool.asset2()));
  }

  /**
   * @dev Returns the address of the pool contract for the given assets.
   * @param asset1 The address of the first asset.
   * @param asset2 The address of the second asset.
   * @return The address of the pool contract.
   */
  function getPoolByAssets(address asset1, address asset2) external view returns (address) {
    return address(getPool[asset1][asset2]);
  }

  /**
   * @dev Returns an array of pool addresses that contain the specified token.
   * @param token The address of the token to search for in the pools.
   * @return An array of pool addresses that contain the specified token.
   */
  function getPoolsByAsset(address token) external view returns (address[] memory) {
    address[] memory pools = new address[](allPools.length);
    uint256 count = 0;

    for (uint256 i = 0; i < allPools.length; i++) {
      IBaluniV1Pool pool = IBaluniV1Pool(pools[i]);
      if (pool.asset1() == token || pool.asset2() == token) {
        pools[count] = address(pool);
        count++;
      }
    }

    address[] memory result = new address[](count);
    for (uint256 i = 0; i < count; i++) {
      result[i] = pools[i];
    }

    return result;
  }
}
