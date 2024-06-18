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
import '../interfaces/IBaluniV1yVault.sol';

contract BaluniV1VaultRegistry is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address[] public allVaults;

    IBaluniV1Registry public registry;

    mapping(address => address) public getVaultType0;
    mapping(address => mapping(address => address)) public getVaultType1;

    event vaultCreated(address indexed vault, address[] assets);

    function initialize(address _register) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(msg.sender);
        registry = IBaluniV1Registry(_register);
    }

    function reinitialize(address _register, uint64 _version) public reinitializer(_version) {
        registry = IBaluniV1Registry(_register);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function addVault(address vaultAddress) external onlyOwner {
        require(vaultAddress != address(0), 'BaluniV1VaultFactory: INVALID_vault_ADDRESS');
        allVaults.push(vaultAddress);
        address baseAsset = IBaluniV1yVault(vaultAddress).baseAsset();
        address quoteAsset = IBaluniV1yVault(vaultAddress).quoteAsset();
        if (quoteAsset == address(0)) {
            getVaultType0[baseAsset] = vaultAddress;
        } else {
            getVaultType1[baseAsset][quoteAsset] = vaultAddress;
            getVaultType1[quoteAsset][baseAsset] = vaultAddress;
        }
    }

    /**
     * @dev Retrieves all the vaults created by the factory.
     * @return An array of vault addresses.
     */
    function getAllvaults() external view returns (address[] memory) {
        return allVaults;
    }

    /**
     * @dev Retrieves the number of vaults created by the factory.
     * @return The count of vaults.
     */
    function getvaultsCount() external view returns (uint256) {
        return allVaults.length;
    }

    /**
     * @dev Retrieves the assets of a specific vault.
     * @param vaultAddress The address of the vault.
     * @return An array of asset addresses.
     */
    function getVaultAsset(address vaultAddress) external view returns (address[] memory) {
        address[] memory assets = new address[](2);
        assets[0] = IBaluniV1yVault(vaultAddress).baseAsset();
        assets[1] = IBaluniV1yVault(vaultAddress).quoteAsset();
        return assets;
    }

    /**
     * @dev Retrieves the vault address based on the given assets.
     * @param asset1 The address of the first asset.
     * @param asset2 The address of the second asset.
     * @return The address of the vault.
     */
    function getVaultType1ByAssets(address asset1, address asset2) external view returns (address) {
        return getVaultType1[asset1][asset2];
    }

    /**
     * @dev Retrieves the address of the vault type 0 associated with the given asset.
     * @param asset The address of the asset.
     * @return The address of the vault type 0 associated with the asset.
     */
    function getVaultType0ByAsset(address asset) external view returns (address) {
        return getVaultType0[asset];
    }

    function getVaultsByAsset(address token) external view returns (address[] memory) {
        address[] memory vaults = new address[](allVaults.length);
        uint256 count = 0;

        for (uint256 i = 0; i < allVaults.length; i++) {
            IBaluniV1yVault vault = IBaluniV1yVault(allVaults[i]);
            address asset = vault.baseAsset();

            if (asset == token) {
                vaults[count] = address(vault);
                count++;
                break;
            }

            if (count == vaults.length) {
                break;
            }
        }

        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = vaults[i];
        }

        return result;
    }

    function vaultExist(address _vault) external view returns (bool) {
        for (uint256 i = 0; i < allVaults.length; i++) {
            if (allVaults[i] == _vault) {
                return true;
            }
        }
        return false;
    }
}
