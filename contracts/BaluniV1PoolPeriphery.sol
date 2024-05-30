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
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

/**
 * @title BaluniV1PoolPeriphery
 * @dev This contract serves as the periphery contract for interacting with BaluniV1Pool contracts.
 * It provides functions for swapping tokens, adding liquidity, removing liquidity, and getting the amount out for a given swap.
 */
contract BaluniV1PoolPeriphery is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IBaluniV1PoolFactory public poolFactory;

    address public treasury;

    uint256 public _MAX_BPS_FEE;
    uint256 public _BPS_FEE;
    uint256 public _BPS_BASE;

    mapping(address => mapping(address => uint256)) public poolsReserves; // Mapping of token address to pool addresses (for quick lookup

    /**
     * @dev Initializes the contract by setting the pool factory address.
     * @param _poolFactory The address of the BaluniV1PoolFactory contract.
     */
    function initialize(address _poolFactory) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(msg.sender);
        poolFactory = IBaluniV1PoolFactory(_poolFactory);
        treasury = msg.sender;
        _MAX_BPS_FEE = 100;
        _BPS_FEE = 30; // 0.3%.
        _BPS_BASE = 10000;
    }

    /**
     * @dev Initializes the contract by setting the pool factory address.
     * @param _poolFactory The address of the BaluniV1PoolFactory contract.
     */
    function reinitialize(address _poolFactory, uint64 version) public reinitializer(version) {
        poolFactory = IBaluniV1PoolFactory(_poolFactory);
        treasury = msg.sender;
        _MAX_BPS_FEE = 100;
        _BPS_FEE = 30; // 0.3%.
        _BPS_BASE = 10000;
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
    function swap(address fromToken, address toToken, uint256 amount, address receiver) external returns (uint256) {
        require(amount > 0, 'Amount must be greater than zero');

        address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);

        IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
        poolsReserves[poolAddress][fromToken] += amount;

        uint256 toSend = pool.swap(fromToken, toToken, amount, receiver);

        uint fee = ((toSend * _BPS_FEE) / _BPS_BASE);
        IERC20(toToken).transfer(treasury, fee);

        toSend -= fee;
        IERC20(toToken).transfer(receiver, toSend);

        poolsReserves[poolAddress][toToken] -= toSend;

        return toSend;
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
    ) external returns (uint256[] memory) {
        require(
            fromTokens.length == toTokens.length &&
                toTokens.length == amounts.length &&
                amounts.length == receivers.length,
            'Input arrays length mismatch'
        );

        uint256[] memory amountsOut = new uint256[](fromTokens.length);

        for (uint256 i = 0; i < fromTokens.length; i++) {
            require(amounts[i] > 0, 'Amount must be greater than zero');
            address poolAddress = poolFactory.getPoolByAssets(fromTokens[i], toTokens[i]);
            IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);

            require(IERC20(fromTokens[i]).balanceOf(msg.sender) >= amounts[i], 'Insufficient Balance');
            IERC20(fromTokens[i]).transferFrom(msg.sender, address(this), amounts[i]);
            poolsReserves[poolAddress][fromTokens[i]] += amounts[i];

            uint256 amountOut = pool.swap(fromTokens[i], toTokens[i], amounts[i], receivers[i]);

            require(IERC20(toTokens[i]).balanceOf(address(this)) >= amountOut, 'Insufficient Liquidity');

            uint fee = ((amountOut * _BPS_FEE) / _BPS_BASE);
            IERC20(toTokens[i]).transfer(treasury, fee);

            amountOut -= fee;
            IERC20(toTokens[i]).transfer(receivers[i], amountOut);

            poolsReserves[poolAddress][toTokens[i]] -= amountOut;
        }

        return amountsOut;
    }

    function rebalanceWeights(address poolAddress, address receiver) external {
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
        uint256[] memory amounts = pool.rebalanceWeights(receiver);
        address[] memory assets = pool.getAssets();
        for (uint256 i = 0; i < assets.length; i++) {
            poolsReserves[poolAddress][assets[i]] += amounts[i];
            IERC20(assets[i]).transferFrom(receiver, address(this), amounts[i]);
        }
    }

    /**
     * @dev Adds liquidity to a BaluniV1Pool.
     * @param amounts An array of amounts for each asset to add as liquidity.
     */
    function addLiquidity(uint256[] calldata amounts, address poolAddress, address receiver) external {
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
        address[] memory assets = pool.getAssets();

        for (uint256 i = 0; i < assets.length; i++) {
            address asset = assets[i];
            uint256 amount = amounts[i];
            IERC20(asset).transferFrom(msg.sender, address(this), amount);
            uint fee = ((amount * _BPS_FEE) / _BPS_BASE);
            IERC20(asset).transfer(treasury, fee);
            poolsReserves[poolAddress][asset] += amount - fee;
        }

        pool.mint(receiver, amounts);
    }

    /**
     * @dev Removes liquidity from a BaluniV1Pool.
     * @param share The amount of liquidity tokens to remove.
     * @param poolAddress The address of the BaluniV1Pool.
     */
    function removeLiquidity(uint256 share, address poolAddress, address receiver) external {
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

        for (uint256 i = 0; i < assets.length; i++) {
            uint fee = ((amountsOut[i] * _BPS_FEE) / _BPS_BASE);
            IERC20(assets[i]).transfer(treasury, fee);
            require(IERC20(assets[i]).balanceOf(address(this)) >= amountsOut[i], 'Insufficient Liquidity');
            poolsReserves[poolAddress][assets[i]] -= amountsOut[i];
            amountsOut[i] -= fee;
            bool assetTransferSuccess = IERC20(assets[i]).transfer(receiver, amountsOut[i]);
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
    function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256) {
        address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
        IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
        return pool.getAmountOut(fromToken, toToken, amount);
    }

    /**
     * @dev Performs rebalance if needed for the given tokens.
     * @param poolAddress The address of the token pool to rebalance.
     */
    function performRebalanceIfNeeded(address poolAddress) external {
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
    function getPoolsContainingToken(address token) external view returns (address[] memory) {
        return poolFactory.getPoolsByAsset(token);
    }

    /**
     * @dev Returns the version of the contract.
     * @return The version string.
     */
    function getVersion() external view returns (uint64) {
        return _getInitializedVersion();
    }

    /**
     * @dev Changes the address of the pool factory contract.
     * Can only be called by the contract owner.
     * @param _poolFactory The new address of the pool factory contract.
     */
    function changePoolFactory(address _poolFactory) external onlyOwner {
        poolFactory = IBaluniV1PoolFactory(_poolFactory);
    }

    /**
     * @dev Changes the treasury address.
     * Can only be called by the contract owner.
     * @param _treasury The new treasury address.
     */
    function changeTreausry(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function getReserves(address pool) public view returns (uint256[] memory) {
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

    /**
     * @dev Changes the basis points fee for the contract.
     * @param _newFee The new basis points fee to be set.
     */
    function changeBpsFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= _MAX_BPS_FEE, 'Fee exceeds maximum');
        _BPS_FEE = _newFee;
    }
}
