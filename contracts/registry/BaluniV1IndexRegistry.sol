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
import '../interfaces/IBaluniV1Registry.sol';
import '../interfaces/IBaluniV1Index.sol';

contract BaluniV1IndexRegistry is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address[] public allIndexes;

    IBaluniV1Registry public registry;

    mapping(address => mapping(address => address)) public getIndex;

    event IndexCreated(address indexed index, address[] assets);

    function initialize(address _register) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(msg.sender);
        registry = IBaluniV1Registry(_register);
    }

    function reinitialize(address _register, uint64 _version) public reinitializer(_version) {
        registry = IBaluniV1Registry(_register);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function addIndex(address indexAddress) external onlyOwner {
        require(indexAddress != address(0), 'BaluniV1IndexRegistry: INVALID_INDEX_ADDRESS');
        allIndexes.push(indexAddress);
        address[] memory assets = IBaluniV1Index(indexAddress).getAssets();
        for (uint256 i = 0; i < assets.length; i++) {
            for (uint256 j = i + 1; j < assets.length; j++) {
                getIndex[assets[i]][assets[j]] = indexAddress;
                getIndex[assets[j]][assets[i]] = indexAddress;
            }
        }
    }

    /**
     * @dev Retrieves all the indexes created by the factory.
     * @return An array of index addresses.
     */
    function getAllIndexes() external view returns (address[] memory) {
        return allIndexes;
    }

    /**
     * @dev Retrieves the number of indexes created by the factory.
     * @return The count of indexes.
     */
    function getIndexesCount() external view returns (uint256) {
        return allIndexes.length;
    }

    /**
     * @dev Retrieves the assets of a specific index.
     * @param indexAddress The address of the index.
     * @return An array of asset addresses.
     */
    function getIndexAssets(address indexAddress) external view returns (address[] memory) {
        IBaluniV1Index index = IBaluniV1Index(indexAddress);
        return index.getAssets();
    }

    /**
     * @dev Retrieves the index address based on the given assets.
     * @param asset1 The address of the first asset.
     * @param asset2 The address of the second asset.
     * @return The address of the index.
     */
    function getIndexByAssets(address asset1, address asset2) external view returns (address) {
        return address(getIndex[asset1][asset2]);
    }

    /**
     * @dev Returns an array of index addresses that contain the specified token.
     * @param token The address of the token to search for.
     * @return An array of index addresses.
     */
    function getIndexesByAsset(address token) external view returns (address[] memory) {
        address[] memory indexes = new address[](allIndexes.length);
        uint256 count = 0;

        for (uint256 i = 0; i < allIndexes.length; i++) {
            IBaluniV1Index index = IBaluniV1Index(allIndexes[i]);
            address[] memory assets = index.getAssets();

            for (uint256 j = 0; j < assets.length; j++) {
                if (assets[j] == token) {
                    indexes[count] = address(index);
                    count++;
                    break;
                }
            }

            if (count == indexes.length) {
                break;
            }
        }

        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = indexes[i];
        }

        return result;
    }

    function indexExist(address _index) external view returns (bool) {
        for (uint256 i = 0; i < allIndexes.length; i++) {
            if (allIndexes[i] == _index) {
                return true;
            }
        }
        return false;
    }

    function removeIndex(address _index) external onlyOwner {
        for (uint256 i = 0; i < allIndexes.length; i++) {
            if (allIndexes[i] == _index) {
                allIndexes[i] = allIndexes[allIndexes.length - 1];
                getIndex[IBaluniV1Index(_index).getAssets()[0]][IBaluniV1Index(_index).getAssets()[1]] = address(0);
                getIndex[IBaluniV1Index(_index).getAssets()[1]][IBaluniV1Index(_index).getAssets()[0]] = address(0);
                allIndexes.pop();
                break;
            }
        }
    }
}
