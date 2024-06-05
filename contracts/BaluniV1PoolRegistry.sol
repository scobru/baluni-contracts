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
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import './interfaces/IBaluniV1Registry.sol';
import './interfaces/IBaluniV1Pool.sol';

contract BaluniV1PoolRegistry is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address[] public allPools;

    IBaluniV1Registry public registry;

    mapping(address => mapping(address => address)) public getPool;

    event PoolCreated(address indexed pool, address[] assets);

    function initialize(address _register) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(msg.sender);
        registry = IBaluniV1Registry(_register);
    }

    function reinitialize(address _register, uint64 _version) public reinitializer(_version) {
        registry = IBaluniV1Registry(_register);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function addPool(address poolAddress) external onlyOwner {
        require(poolAddress != address(0), 'BaluniV1PoolFactory: INVALID_POOL_ADDRESS');
        allPools.push(poolAddress);
    }

    /**
     * @dev Retrieves all the pools created by the factory.
     * @return An array of pool addresses.
     */
    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }

    /**
     * @dev Retrieves the number of pools created by the factory.
     * @return The count of pools.
     */
    function getPoolsCount() external view returns (uint256) {
        return allPools.length;
    }

    /**
     * @dev Retrieves the assets of a specific pool.
     * @param poolAddress The address of the pool.
     * @return An array of asset addresses.
     */
    function getPoolAssets(address poolAddress) external view returns (address[] memory) {
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
        return pool.getAssets();
    }

    /**
     * @dev Retrieves the pool address based on the given assets.
     * @param asset1 The address of the first asset.
     * @param asset2 The address of the second asset.
     * @return The address of the pool.
     */
    function getPoolByAssets(address asset1, address asset2) external view returns (address) {
        return address(getPool[asset1][asset2]);
    }

    /**
     * @dev Returns an array of pool addresses that contain the specified token.
     * @param token The address of the token to search for.
     * @return An array of pool addresses.
     */
    function getPoolsByAsset(address token) external view returns (address[] memory) {
        address[] memory pools = new address[](allPools.length);
        uint256 count = 0;

        for (uint256 i = 0; i < allPools.length; i++) {
            IBaluniV1Pool pool = IBaluniV1Pool(allPools[i]);
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

    function poolExist(address _pool) external view returns (bool) {
        for (uint256 i = 0; i < allPools.length; i++) {
            if (allPools[i] == _pool) {
                return true;
            }
        }
        return false;
    }
}
