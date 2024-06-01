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
import './interfaces/IBaluniV1PoolFactory.sol';
import './interfaces/IBaluniV1Pool.sol';
import './interfaces/IBaluniV1PoolPeriphery.sol';

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import './interfaces/IBaluniV1Registry.sol';

/**
 * @title BaluniV1PoolPeriphery
 * @dev This contract serves as the periphery contract for interacting with BaluniV1Pool contracts.
 * It provides functions for swapping tokens, adding liquidity, removing liquidity, and getting the amount out for a given swap.
 */
contract BaluniV1PoolPeriphery is Initializable, OwnableUpgradeable, UUPSUpgradeable, IBaluniV1PoolPeriphery {
    IBaluniV1Registry public registry;

    mapping(address => mapping(address => uint256)) public poolsReserves; // Mapping of token address to pool addresses (for quick lookup

    function initialize(address _registry) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(msg.sender);
        registry = IBaluniV1Registry(_registry);
    }

    function reinitialize(address _registry, uint64 version) public reinitializer(version) {
        registry = IBaluniV1Registry(_registry);
    }

    /**
     * @dev Internal function to authorize an upgrade to a new implementation contract.
     * @param newImplementation The address of the new implementation contract.
     * @notice This function can only be called by the contract owner.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Swaps tokens in a BaluniV1Pool.
     * @param fromToken The address of the token to swap from.
     * @param toToken The address of the token to swap to.
     * @param amount The amount of tokens to swap.
     * @return The amount of tokens received after the swap.
     */
    function swap(
        address fromToken,
        address toToken,
        uint256 amount,
        address receiver
    ) public override returns (uint256) {
        IBaluniV1PoolFactory poolFactory = IBaluniV1PoolFactory(registry.getBaluniPoolFactory());
        require(amount > 0, 'Amount must be greater than zero');

        address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);

        IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
        poolsReserves[poolAddress][fromToken] += amount;

        uint256 amountOut = pool.swap(fromToken, toToken, amount, receiver);

        poolsReserves[poolAddress][toToken] -= amountOut;

        IERC20(toToken).transfer(receiver, amountOut);

        return amountOut;
    }

    /**
     * @dev Performs batch swaps between multiple token pairs.
     * @param fromTokens An array of addresses representing the tokens to swap from.
     * @param toTokens An array of addresses representing the tokens to swap to.
     * @param amounts An array of amounts representing the amounts to swap.
     * @param receivers An array of addresses representing the receivers of the swapped tokens.
     * @return An array of amounts representing the amounts of tokens received after the swaps.
     */
    function batchSwap(
        address[] calldata fromTokens,
        address[] calldata toTokens,
        uint256[] calldata amounts,
        address[] calldata receivers
    ) external override returns (uint256[] memory) {
        require(
            fromTokens.length == toTokens.length &&
                toTokens.length == amounts.length &&
                amounts.length == receivers.length,
            'Input arrays length mismatch'
        );

        uint256[] memory amountsOut = new uint256[](fromTokens.length);

        for (uint256 i = 0; i < fromTokens.length; i++) {
            require(amounts[i] > 0, 'Amount must be greater than zero');

            address fromToken = fromTokens[i];
            address toToken = toTokens[i];

            uint256 amount = amounts[i];
            address receiver = receivers[i];

            require(IERC20(fromToken).balanceOf(msg.sender) >= amount, 'Insufficient Balance');
            amountsOut[i] = swap(fromToken, toToken, amount, receiver);
        }

        return amountsOut;
    }

    function rebalanceWeights(address poolAddress, address receiver) external override {
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);

        uint256[] memory amounts = pool.rebalanceWeights(receiver);
        address[] memory assets = pool.getAssets();

        for (uint256 i = 0; i < assets.length; i++) {
            poolsReserves[poolAddress][assets[i]] += amounts[i];
            IERC20(assets[i]).transferFrom(receiver, address(this), amounts[i]);
        }
    }

    function addLiquidity(
        uint256[] memory amounts,
        address poolAddress,
        address receiver
    ) external override returns (uint256) {
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
        address[] memory assets = pool.getAssets();

        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).transferFrom(msg.sender, address(this), amounts[i]);
            poolsReserves[poolAddress][assets[i]] += amounts[i];
        }

        return pool.mint(receiver, amounts);
    }

    function removeLiquidity(uint256 share, address poolAddress, address receiver) external override {
        address treasury = registry.getTreasury();
        uint256 _BPS_FEE = registry.getBPS_FEE();
        uint256 _BPS_BASE = registry.getBPS_BASE();
        require(share > 0, 'Share must be greater than zero');
        IERC20 poolToken = IERC20(poolAddress);

        // Check allowance
        uint256 allowance = poolToken.allowance(msg.sender, address(this));
        require(allowance >= share, 'Insufficient allowance');

        // Check balance
        uint256 balance = poolToken.balanceOf(msg.sender);
        require(balance >= share, 'Insufficient balance');

        bool success = poolToken.transferFrom(msg.sender, address(this), share);
        require(success, 'TransferFrom failed');

        bool success2 = poolToken.transfer(poolAddress, share);
        require(success2, 'Transfer failed');

        uint256[] memory amountsOut = IBaluniV1Pool(poolAddress).burn(receiver);

        address[] memory assets = IBaluniV1Pool(poolAddress).getAssets();
        address _poolAddress = poolAddress;
        address _receiver = receiver;

        for (uint256 i = 0; i < assets.length; i++) {
            uint fee = ((amountsOut[i] * _BPS_FEE) / _BPS_BASE);
            IERC20(assets[i]).transfer(treasury, fee);
            require(IERC20(assets[i]).balanceOf(address(this)) >= amountsOut[i], 'Insufficient Liquidity');
            poolsReserves[_poolAddress][assets[i]] -= amountsOut[i];
            amountsOut[i] -= fee;
            bool assetTransferSuccess = IERC20(assets[i]).transfer(_receiver, amountsOut[i]);
            require(assetTransferSuccess, 'Asset transfer failed');
        }
    }

    /**
     * @dev Gets the amount of tokens received after a swap in a BaluniV1Pool.
     * @param fromToken The address of the token to swap from.
     * @param toToken The address of the token to swap to.
     * @param amount The amount of tokens to swap.
     * @return The amount of tokens received after the swap.
     */
    function getAmountOut(address fromToken, address toToken, uint256 amount) external view override returns (uint256) {
        IBaluniV1PoolFactory poolFactory = IBaluniV1PoolFactory(registry.getBaluniPoolFactory());
        address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
        return pool.getAmountOut(fromToken, toToken, amount);
    }

    /**
     * @dev Performs rebalance if needed for the given tokens.
     * @param poolAddress The address of the token pool to rebalance.
     */
    function performRebalanceIfNeeded(address poolAddress) external override {
        uint256 _BPS_BASE = registry.getBPS_BASE();
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
        uint256 balance = IERC20(poolAddress).balanceOf(msg.sender);
        uint256 totalSupply = IERC20(poolAddress).totalSupply();
        require((balance * _BPS_BASE) / totalSupply >= 100, 'Insufficient balance');
        (uint256[] memory amountsToAdd, uint256[] memory amountsToRemove) = pool.performRebalanceIfNeeded();

        // update Pool reserves
        address[] memory assets = pool.getAssets();
        for (uint256 i = 0; i < assets.length; i++) {
            poolsReserves[poolAddress][assets[i]] += amountsToAdd[i];
            poolsReserves[poolAddress][assets[i]] -= amountsToRemove[i];
        }
    }

    /**
     * @dev Returns an array of pool addresses that contain the given token.
     * @param token The address of the token to search for.
     * @return An array of pool addresses.
     */
    function getPoolsContainingToken(address token) external view override returns (address[] memory) {
        IBaluniV1PoolFactory poolFactory = IBaluniV1PoolFactory(registry.getBaluniPoolFactory());
        return poolFactory.getPoolsByAsset(token);
    }

    /**
     * @dev Returns the version of the contract.
     * @return The version string.
     */
    function getVersion() external view override returns (uint64) {
        return _getInitializedVersion();
    }

    function getReserves(address pool) public view override returns (uint256[] memory) {
        address[] memory assets = IBaluniV1Pool(pool).getAssets();
        uint256[] memory reserves = new uint256[](assets.length);
        for (uint256 i = 0; i < assets.length; i++) {
            reserves[i] = poolsReserves[pool][assets[i]];
        }
        return reserves;
    }

    function getAssetReserve(address pool, address asset) external view returns (uint256) {
        return poolsReserves[pool][asset];
    }
}
