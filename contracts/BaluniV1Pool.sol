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
import './interfaces/IBaluniV1Rebalancer.sol';
import './interfaces/IBaluniV1Router.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

import './interfaces/IBaluniV1PoolPeriphery.sol';

contract BaluniV1Pool is ERC20, ReentrancyGuard {
    AssetInfo[] public assetInfos;
    uint256 public trigger;
    uint256 public ONE;
    address public periphery;
    address public factory;
    uint256 public constant SWAP_FEE_BPS = 30; // 0.3%
    address public baseAsset;
    address public rebalancer;

    struct AssetInfo {
        address asset;
        uint256 weight;
    }

    event RebalancePerformed(address indexed by, address[] assets);
    event WeightsRebalanced(address indexed user, uint256[] amountsAdded);
    event Burn(address indexed user, uint256 sharesBurned);
    event Mint(address indexed to, uint256 sharesMinted);
    event Swap(
        address indexed user,
        address indexed fromToken,
        address indexed toToken,
        uint256 amountIn,
        uint256 amountOut
    );

    /**
     * @dev Initializes a new instance of the BaluniV1Pool contract.
     * @param _rebalancer The address of the rebalancer contract.
     * @param _assets An array of addresses representing the assets in the pool.
     * @param _weights An array of weights corresponding to the assets in the pool.
     * @param _trigger The trigger value for rebalancing the pool.
     * @param _periphery The address of the periphery contract.
     */
    constructor(
        address _rebalancer,
        address[] memory _assets,
        uint256[] memory _weights,
        uint256 _trigger,
        address _periphery
    ) ERC20('Baluni LP', 'BALUNI-LP') {
        // Initialize contract state variables
        periphery = _periphery;
        factory = msg.sender;
        rebalancer = _rebalancer;
        ONE = 1e18;

        // Initialize assets and weights
        initializeAssets(_assets, _weights);

        // Set trigger value
        trigger = _trigger;

        // Set base asset
        baseAsset = IBaluniV1Rebalancer(_rebalancer).USDC();
        //baseAsset = IBaluniV1Rebalancer(_rebalancer).WNATIVE();

        // Ensure the sum of weights equals 10000
        uint256 totalWeight = 0;
        for (uint256 i = 0; i < _weights.length; i++) {
            totalWeight += _weights[i];
        }
        require(totalWeight == 10000, 'Invalid weights');
    }

    modifier onlyPeriphery() {
        require(msg.sender == periphery, 'Only Periphery');
        _;
    }

    /**
     * @dev Initializes the assets and their weights for the pool.
     * @param _assets The array of asset addresses.
     * @param _weights The array of weights corresponding to each asset.
     */
    function initializeAssets(address[] memory _assets, uint256[] memory _weights) internal {
        require(_assets.length == _weights.length, 'Assets and weights length mismatch');

        for (uint256 i = 0; i < _assets.length; i++) {
            require(_assets[i] != address(0), 'Invalid asset address');
            require(_weights[i] > 0, 'Invalid weight');

            assetInfos.push(AssetInfo({asset: _assets[i], weight: _weights[i]}));

            IERC20 asset = IERC20(_assets[i]);
            if (asset.allowance(address(this), address(rebalancer)) == 0) {
                asset.approve(address(rebalancer), type(uint256).max);
            }
        }
    }

    /**
     * @dev Rebalances the weights of the pool by calculating the amounts to add for each token,
     * transferring the calculated amounts from the user to the pool, minting the total added liquidity,
     * updating the reserves, and emitting an event to indicate the rebalancing of weights.
     * @param receiver The address to receive the minted liquidity tokens.
     */
    function rebalanceWeights(address receiver) external onlyPeriphery returns (uint256[] memory) {
        require(isRebalanceNeeded(), 'Rebalance not needed');
        (uint256 totalValuation, uint256[] memory valuations) = _computeTotalValuation();

        uint256[] memory amountsToAdd = _calculateAmountsToAdd(totalValuation, valuations);

        // Calculate total added liquidity before minting
        uint256 totalAddedLiquidity = _calculateTotalAddedLiquidity(amountsToAdd);

        uint baseDecimal = IERC20Metadata(baseAsset).decimals();

        totalAddedLiquidity *= 10 ** 18 - baseDecimal;

        uint256[] memory amounts = new uint256[](assetInfos.length);

        for (uint256 i = 0; i < amountsToAdd.length; i++) {
            if (amountsToAdd[i] > 0) {
                amounts[i] = _calculateLiquidity(i, amountsToAdd[i]);
            }
        }

        _mint(receiver, totalAddedLiquidity);

        emit WeightsRebalanced(msg.sender, amountsToAdd);

        return amounts;
    }

    /**
     * @dev Swaps `amount` of `fromToken` to `toToken` and transfers the received amount to `receiver`.
     *
     * Requirements:
     * - `fromToken` and `toToken` must be different tokens.
     * - `amount` must be greater than zero.
     * - Sufficient liquidity of `toToken` must be available in the contract.
     *
     * Emits a `Swap` event with the details of the swap.
     *
     * Updates the reserves after the swap.
     *
     * @param fromToken The address of the token to swap from.
     * @param toToken The address of the token to swap to.
     * @param amount The amount of `fromToken` to swap.
     * @param receiver The address to receive the swapped tokens.
     * @return toSend The amount of `toToken` received after the swap.
     */
    function swap(
        address fromToken,
        address toToken,
        uint256 amount,
        address receiver
    ) external nonReentrant returns (uint256 toSend) {
        require(fromToken != toToken, 'Cannot swap the same token');
        require(amount > 0, 'Amount must be greater than zero');

        uint256 receivedAmount = getAmountOut(fromToken, toToken, amount);

        require(getAssetReserve(toToken) >= receivedAmount, 'Insufficient Liquidity');

        uint256 fee = (receivedAmount * SWAP_FEE_BPS) / 10000;
        toSend = receivedAmount - fee;

        emit Swap(receiver, fromToken, toToken, amount, toSend);

        return toSend;
    }

    /**
     * @dev Mints new tokens and adds them to the specified address.
     * @param to The address to which the new tokens will be minted.
     * @return The amount of tokens minted.
     */
    function mint(address to, uint256[] memory amounts) external onlyPeriphery returns (uint256) {
        uint256 totalSupply = totalSupply();
        uint256 totalValue = 0;
        uint256[] memory _reserves = getReserves();
        require(assetInfos.length == _reserves.length, 'Invalid reserves length');
        require(assetInfos.length > 0, 'No assets');

        for (uint256 i = 0; i < assetInfos.length; i++) {
            address asset = assetInfos[i].asset;

            uint256 valuation = _convertTokenToBase(asset, amounts[i]);
            totalValue += valuation;
        }

        require(totalValue > 0, 'Total value must be greater than 0');

        uint256 toMint;

        // Calculate total added liquidity before minting

        uint baseDecimal = IERC20Metadata(baseAsset).decimals();

        if (totalSupply == 0) {
            toMint = totalValue * 10 ** 18 - baseDecimal;
        } else {
            (uint256 totalLiquidity, ) = _computeTotalValuation();
            require(totalLiquidity > 0, 'Total liquidity must be greater than 0');
            toMint = (((totalValue) * totalSupply) / totalLiquidity) * 10 ** 18 - baseDecimal;
        }
        require(toMint != 0, 'Mint qty is 0');

        uint256 b4 = balanceOf(msg.sender);
        _mint(to, toMint);
        uint256 b = balanceOf(to) - b4;

        require(b == toMint, 'Mint Failed');

        emit Mint(to, toMint);

        return toMint;
    }

    /**
     * @dev Burns the pool tokens and transfers the underlying assets to the specified address.
     * @param to The address to transfer the underlying assets to.
     * @notice This function can only be called by the periphery contract.
     * @notice The pool tokens must have a balance greater than 0.
     * @notice The total supply of pool tokens must be greater than 0.
     * @notice The function calculates the amounts of each underlying asset to transfer based on the share of pool tokens being burned.
     * @notice A fee is deducted from the share of pool tokens being burned and transferred to the treasury address.
     * @notice The function checks if the pool has sufficient liquidity before performing any transfers.
     * @notice If any transfer fails, the function reverts the entire operation.
     * @notice After the transfers, the function updates the reserves of the pool.
     * @notice Emits a `Burn` event with the address and share of pool tokens burned.
     */
    function burn(address to) external onlyPeriphery returns (uint256[] memory) {
        uint256 share = balanceOf(address(this));
        require(share > 0, 'Share must be greater than 0');

        uint256 totalSupply = totalSupply();
        require(totalSupply > 0, 'No liquidity');

        uint256[] memory amounts = new uint256[](assetInfos.length);
        uint256 fee = (share * SWAP_FEE_BPS) / 10000;
        uint256 shareAfterFee = share - fee;

        for (uint256 i = 0; i < assetInfos.length; i++) {
            uint256 assetBalance = IBaluniV1PoolPeriphery(periphery).getAssetReserve(
                address(this),
                assetInfos[i].asset
            );
            amounts[i] = (assetBalance * shareAfterFee) / totalSupply;
        }

        require(balanceOf(address(this)) >= shareAfterFee, 'Insufficient BALUNI liquidity');

        bool feeTransferSuccess = IERC20(address(this)).transfer(IBaluniV1Rebalancer(rebalancer).treasury(), fee);
        require(feeTransferSuccess, 'Fee transfer failed');

        _burn(address(this), shareAfterFee);

        emit Burn(to, shareAfterFee);

        return amounts;
    }

    /**
     * @dev Calculates the amount of `toToken` that will be received when swapping `fromToken` for `toToken`.
     * @param fromToken The address of the token being swapped from.
     * @param toToken The address of the token being swapped to.
     * @param amount The amount of `fromToken` being swapped.
     * @return The amount of `toToken` that will be received.
     */
    function getAmountOut(address fromToken, address toToken, uint256 amount) public view returns (uint256) {
        return IBaluniV1Rebalancer(rebalancer).convert(fromToken, toToken, amount);
    }

    /**
     * @dev Performs rebalance
     */
    function performRebalanceIfNeeded()
        external
        onlyPeriphery
        returns (uint256[] memory amountsToAdd, uint256[] memory amountsToRemove)
    {
        require(isRebalanceNeeded(), 'Rebalance not needed');
        return _performRebalanceIfNeeded();
    }

    /**
     * @dev Returns the deviation between the current weights and target weights of the assets in the pool.
     * @return directions An array of boolean values indicating whether the current weight is higher (true) or lower (false) than the target weight.
     */
    function getDeviation() public view returns (bool[] memory directions, uint256[] memory deviations) {
        (uint256 totVal, uint256[] memory valuations) = _computeTotalValuation();
        uint256 numAssets = assetInfos.length;

        directions = new bool[](numAssets);
        deviations = new uint256[](numAssets);

        for (uint256 i = 0; i < numAssets; i++) {
            uint256 currentWeight = (valuations[i] * 10000) / totVal;
            uint256 targetWeight = assetInfos[i].weight;

            if (currentWeight > targetWeight) {
                deviations[i] = currentWeight - targetWeight;
                directions[i] = true;
            } else {
                deviations[i] = targetWeight - currentWeight;
                directions[i] = false;
            }
        }

        return (directions, deviations);
    }

    /**
     * @dev Returns the liquidity of a specific asset in the pool.
     * @param assetIndex The index of the asset.
     * @return The liquidity of the asset.
     */
    function assetLiquidity(uint256 assetIndex) external view returns (uint256) {
        (, uint256[] memory usdValuations) = _computeTotalValuation();
        require(assetIndex < usdValuations.length, 'Invalid asset index');
        return usdValuations[assetIndex];
    }

    /**
     * @dev Computes the total valuation of the pool and returns the total valuation and an array of individual valuations.
     * @return totalVal The total valuation of the pool.
     * @return valuations An array of individual valuations.
     */
    function computeTotalValuation() external view returns (uint256 totalVal, uint256[] memory valuations) {
        (totalVal, valuations) = _computeTotalValuation();
        return (totalVal, valuations);
    }

    /**
     * @dev Returns the total liquidity of the pool.
     * @return The total liquidity of the pool.
     */
    function liquidity() external view returns (uint256) {
        (uint256 totalVal, ) = _computeTotalValuation();
        return totalVal;
    }

    /**
     * @dev Returns the unit price of the pool.
     * @return The unit price of the pool.
     */
    function unitPrice() external view returns (uint256) {
        (uint256 totalVal, ) = _computeTotalValuation();
        uint256 totalSupply = totalSupply();
        if (totalSupply == 0) {
            return 0;
        }
        return (totalVal * ONE) / totalSupply;
    }

    /**
     * @dev Returns an array of reserves for each asset in the pool.
     * @return An array of reserves.
     */
    function getReserves() public view returns (uint256[] memory) {
        return IBaluniV1PoolPeriphery(periphery).getReserves(address(this));
    }

    /**
     * @dev Returns the reserve amount of the specified asset.
     * @param asset The address of the asset.
     * @return The reserve amount of the asset.
     */
    function getAssetReserve(address asset) public view returns (uint256) {
        return IBaluniV1PoolPeriphery(periphery).getAssetReserve(address(this), asset);
    }

    /**
     * @dev Retrieves the list of assets in the pool.
     * @return An array of addresses representing the assets.
     */
    function getAssets() external view returns (address[] memory) {
        address[] memory assets = new address[](assetInfos.length);
        for (uint256 i = 0; i < assetInfos.length; i++) {
            assets[i] = assetInfos[i].asset;
        }
        return assets;
    }

    /**
     * @dev Retrieves the list of weights associated with the assets in the pool.
     * @return An array of uint256 values representing the weights.
     */
    function getWeights() external view returns (uint256[] memory) {
        uint256[] memory weights = new uint256[](assetInfos.length);
        for (uint256 i = 0; i < assetInfos.length; i++) {
            weights[i] = assetInfos[i].weight;
        }
        return weights;
    }

    /**
     * @dev Computes the total valuation of the assets in the pool.
     * @return totalValuation The total valuation of the assets.
     * @return valuations An array of valuations for each asset in the pool.
     */
    function _computeTotalValuation() internal view returns (uint256 totalValuation, uint256[] memory valuations) {
        uint256 numAssets = assetInfos.length;
        valuations = new uint256[](numAssets);
        for (uint256 i = 0; i < numAssets; i++) {
            address asset = assetInfos[i].asset;
            uint256 assetReserve = getAssetReserve(address(asset));

            if ((address(asset) == baseAsset)) {
                valuations[i] = assetReserve;
            } else {
                uint256 valuation = _convertTokenToBase(address(asset), assetReserve);
                valuations[i] = valuation;
            }
            totalValuation += valuations[i];
        }
        return (totalValuation, valuations);
    }

    /**
     * @dev Performs rebalance if needed.
     * This function retrieves the assets and weights from the `assetInfos` array,
     * and calls the `rebalance` function of the `rebalancer` contract with the retrieved values.
     * It emits a `RebalancePerformed` event after the rebalance is performed.
     * @notice This function should only be called internally.
     */
    function _performRebalanceIfNeeded() internal returns (uint256[] memory, uint256[] memory) {
        address[] memory assets = new address[](assetInfos.length);
        uint256[] memory weights = new uint256[](assetInfos.length);
        uint256[] memory peripheryBalancesB4 = new uint256[](assetInfos.length);
        uint256[] memory peripheryBalancesAfter = new uint256[](assetInfos.length);
        uint256[] memory amountsToAdd = new uint256[](assetInfos.length);
        uint256[] memory amountsToRemove = new uint256[](assetInfos.length);

        for (uint256 i = 0; i < assetInfos.length; i++) {
            assets[i] = assetInfos[i].asset;
            weights[i] = assetInfos[i].weight;
            peripheryBalancesB4[i] = IERC20(assets[i]).balanceOf(periphery);
        }

        uint256[] memory balances = getReserves();

        IBaluniV1Rebalancer(rebalancer).rebalance(balances, assets, weights, trigger, periphery, periphery, baseAsset);

        for (uint256 i = 0; i < assetInfos.length; i++) {
            peripheryBalancesAfter[i] = IERC20(assets[i]).balanceOf(periphery);

            if (peripheryBalancesAfter[i] > peripheryBalancesB4[i]) {
                amountsToAdd[i] = peripheryBalancesAfter[i] - peripheryBalancesB4[i];
            } else {
                amountsToRemove[i] = peripheryBalancesB4[i] - peripheryBalancesAfter[i];
            }
        }

        emit RebalancePerformed(msg.sender, assets);

        return (amountsToAdd, amountsToRemove);
    }

    /**
     * @dev Calculates the total added liquidity based on the amounts to add.
     * @param amountsToAdd An array of amounts to add for each asset.
     * @return totalAddedLiquidity The total added liquidity.
     */
    function _calculateTotalAddedLiquidity(
        uint256[] memory amountsToAdd
    ) internal view returns (uint256 totalAddedLiquidity) {
        for (uint256 i = 0; i < assetInfos.length; i++) {
            totalAddedLiquidity += amountsToAdd[i];
        }
        return totalAddedLiquidity;
    }

    /**
     * @dev Calculates the amounts to add to each asset based on the total valuation and current valuations.
     * @param totalValuation The total valuation of the pool.
     * @param valuations An array of current valuations for each asset.
     * @return amountsToAdd An array of amounts to add to each asset.
     */
    function _calculateAmountsToAdd(
        uint256 totalValuation,
        uint256[] memory valuations
    ) internal view returns (uint256[] memory amountsToAdd) {
        amountsToAdd = new uint256[](assetInfos.length);
        for (uint256 i = 0; i < assetInfos.length; i++) {
            uint256 targetValuation = (totalValuation * assetInfos[i].weight) / 10000;
            if (valuations[i] < targetValuation) {
                amountsToAdd[i] = targetValuation - valuations[i];
            }
        }
        return amountsToAdd;
    }

    /**
     * @dev Internal function to transfer tokens from the caller to the contract and calculate the liquidity.
     * @param index The index of the asset in the assetInfos array.
     * @param amountToAdd The amount of native tokens to add as liquidity.
     */
    function _calculateLiquidity(uint256 index, uint256 amountToAdd) internal view returns (uint256) {
        uint256 tokenAmount = _convertBaseToToken(assetInfos[index].asset, amountToAdd);
        require(tokenAmount > 0, 'Invalid token amount to add');
        return tokenAmount;
    }

    /**
     * @dev Converts the specified amount of native token to the corresponding token amount.
     * @param fromToken The address of the native token to convert from.
     * @param amount The amount of native token to convert.
     * @return The corresponding token amount.
     */
    function _convertBaseToToken(address fromToken, uint256 amount) internal view returns (uint256) {
        uint256 tokenAmount = IBaluniV1Rebalancer(rebalancer).convert(baseAsset, fromToken, amount);
        return tokenAmount;
    }

    /**
     * @dev Returns the maximum of two uint8 values.
     * @param a The first uint8 value.
     * @param b The second uint8 value.
     * @return The maximum value between a and b.
     */
    function max(uint8 a, uint8 b) private pure returns (uint8) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the minimum of two uint8 values.
     * @param a The first uint8 value.
     * @param b The second uint8 value.
     * @return The minimum value between a and b.
     */
    function min(uint8 a, uint8 b) private pure returns (uint8) {
        return a <= b ? a : b;
    }

    /**
     * @dev Converts the specified token to the native token using the rebalancer contract.
     * @param fromToken The address of the token to convert from.
     * @param amount The amount of tokens to convert.
     * @return scaledAmount The converted amount of tokens.
     */
    function _convertTokenToBase(address fromToken, uint256 amount) internal view returns (uint256 scaledAmount) {
        uint256 tokenAmount = IBaluniV1Rebalancer(rebalancer).convert(fromToken, baseAsset, amount);
        return tokenAmount;
    }

    // return true if one of the deviation overcome the trigger
    /**
     * @dev Checks if rebalancing is needed for the pool.
     * @return A boolean value indicating whether rebalancing is needed or not.
     */
    function isRebalanceNeeded() public view returns (bool) {
        (bool[] memory directions, uint256[] memory deviations) = getDeviation();
        for (uint256 i = 0; i < deviations.length; i++) {
            if (directions[i] && deviations[i] > trigger) {
                return true;
            }
        }
        return false;
    }
}
