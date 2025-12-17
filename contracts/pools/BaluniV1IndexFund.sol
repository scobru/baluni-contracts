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
 * Baluni Index Fund - A tokenized index fund with configurable weights
 */

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol';

import '../interfaces/IBaluniV1Registry.sol';
import '../interfaces/IBaluniV1Rebalancer.sol';
import '../interfaces/IBaluniV1Oracle.sol';
import '../interfaces/IBaluniV1IndexFund.sol';

contract BaluniV1IndexFund is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ERC20Upgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    IBaluniV1IndexFund
{
    /// @notice Array storing information about each asset in the fund
    AssetInfo[] public assetInfos;

    /// @notice Constant representing 1e18 for calculations
    uint256 public ONE;

    /// @notice The base asset (USDC) used for valuations
    address public baseAsset;

    /// @notice Scaling factor for decimal normalization
    uint256 private scalingFactor;

    /// @notice The registry contract for the Baluni ecosystem
    IBaluniV1Registry public registry;

    /// @notice Mapping of reserves for each asset
    mapping(address => uint256) public reserves;

    /**
     * @dev Modifier to ensure the deadline has not passed
     */
    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

    /**
     * @dev Initializes the BaluniV1IndexFund contract
     * @param _name The name of the fund token
     * @param _symbol The symbol of the fund token
     * @param _assets Array of asset addresses
     * @param _weights Array of asset weights (must sum to 10000)
     * @param _registry Address of the Baluni registry
     */
    function initialize(
        string memory _name,
        string memory _symbol,
        address[] memory _assets,
        uint256[] memory _weights,
        address _registry
    ) external initializer {
        __Ownable_init(msg.sender);
        __ERC20_init(_name, _symbol);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        registry = IBaluniV1Registry(_registry);
        ONE = 1e18;
        baseAsset = registry.getUSDC();
        scalingFactor = 10 ** (18 - 6);

        require(baseAsset != address(0), 'Invalid base asset address');
        require(_initializeAssets(_assets, _weights), 'Initialization failed');

        uint256 totalWeight = 0;
        for (uint256 i = 0; i < _weights.length; i++) {
            totalWeight += _weights[i];
        }
        require(totalWeight == 10000, 'Invalid weights');
    }

    /**
     * @dev Reinitializes the contract for upgrades
     */
    function reinitialize(
        string memory _name,
        string memory _symbol,
        address[] memory _assets,
        uint256[] memory _weights,
        address _registry,
        uint64 _version
    ) external reinitializer(_version) {
        __Ownable_init(msg.sender);
        __ERC20_init(_name, _symbol);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        registry = IBaluniV1Registry(_registry);
        ONE = 1e18;
        baseAsset = registry.getUSDC();
        scalingFactor = 10 ** (18 - 6);

        require(baseAsset != address(0), 'Invalid base asset address');
        require(_initializeAssets(_assets, _weights), 'Initialization failed');

        uint256 totalWeight = 0;
        for (uint256 i = 0; i < _weights.length; i++) {
            totalWeight += _weights[i];
        }
        require(totalWeight == 10000, 'Invalid weights');
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Initializes assets and their target weights
     */
    function _initializeAssets(address[] memory _assets, uint256[] memory _weights) internal returns (bool) {
        address rebalancer = registry.getBaluniRebalancer();

        require(rebalancer != address(0), 'Invalid rebalancer address');
        require(_assets.length == _weights.length, 'Assets and weights length mismatch');

        delete assetInfos;

        for (uint256 i = 0; i < _assets.length; i++) {
            require(_assets[i] != address(0), 'Invalid asset address');
            require(_weights[i] > 0, 'Invalid weight');

            assetInfos.push(
                AssetInfo({
                    asset: _assets[i],
                    weight: _weights[i],
                    reserve: 0
                })
            );

            IERC20 asset = IERC20(_assets[i]);
            if (asset.allowance(address(this), address(rebalancer)) == 0) {
                asset.approve(address(rebalancer), type(uint256).max);
            }
        }
        return true;
    }

    // ============================================
    // DEPOSIT FUNCTIONS
    // ============================================

    /**
     * @dev Deposits multiple assets proportionally to receive fund shares
     * @param to Address to receive the fund shares
     * @param amounts Array of amounts for each asset
     * @param deadline Transaction deadline
     * @return Amount of shares minted
     */
    function deposit(
        address to,
        uint256[] memory amounts,
        uint256 deadline
    ) external override ensure(deadline) nonReentrant whenNotPaused returns (uint256) {
        uint256 totalSupply = totalSupply();
        uint256 totalValue = 0;

        require(amounts.length == assetInfos.length, 'Invalid amounts length');
        require(assetInfos.length > 0, 'No assets');

        for (uint256 i = 0; i < assetInfos.length; i++) {
            if (amounts[i] == 0) continue;

            address asset = assetInfos[i].asset;
            bool success = IERC20(asset).transferFrom(msg.sender, address(this), amounts[i]);
            require(success, 'Transfer from failed');

            uint256 valuation;
            if (asset == baseAsset) {
                valuation = amounts[i];
            } else {
                valuation = _convertTokenToBase(asset, amounts[i]);
            }
            totalValue += valuation;
        }

        require(totalValue > 0, 'Total value must be greater than 0');

        uint256 toMint;
        if (totalSupply == 0) {
            toMint = totalValue * scalingFactor;
        } else {
            (uint256 totalLiquidity, ) = _computeTotalValuation();
            require(totalLiquidity > 0, 'Total liquidity must be greater than 0');
            toMint = ((totalValue * scalingFactor) * totalSupply) / (totalLiquidity * scalingFactor);
        }

        require(toMint != 0, 'Mint qty is 0');

        _mint(to, toMint);
        _update();

        emit Deposit(to, toMint);
        return toMint;
    }

    /**
     * @dev Deposits a single asset to receive fund shares
     * @param token The token to deposit
     * @param amount The amount to deposit
     * @param to Address to receive the fund shares
     * @param deadline Transaction deadline
     * @return Amount of shares minted
     */
    function depositSingle(
        address token,
        uint256 amount,
        address to,
        uint256 deadline
    ) external override ensure(deadline) nonReentrant whenNotPaused returns (uint256) {
        require(token != address(0), 'Invalid token address');
        require(amount > 0, 'Amount must be greater than 0');
        require(_isValidAsset(token), 'Token not in fund');

        uint256 totalSupply = totalSupply();

        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, 'Transfer from failed');

        uint256 valuation;
        if (token == baseAsset) {
            valuation = amount;
        } else {
            valuation = _convertTokenToBase(token, amount);
        }

        require(valuation > 0, 'Valuation must be greater than 0');

        uint256 toMint;
        if (totalSupply == 0) {
            toMint = valuation * scalingFactor;
        } else {
            (uint256 totalLiquidity, ) = _computeTotalValuation();
            require(totalLiquidity > 0, 'Total liquidity must be greater than 0');
            toMint = ((valuation * scalingFactor) * totalSupply) / (totalLiquidity * scalingFactor);
        }

        require(toMint != 0, 'Mint qty is 0');

        _mint(to, toMint);
        _update();

        emit DepositSingle(to, token, amount, toMint);
        return toMint;
    }

    /**
     * @dev Rebalances the fund and allows user to deposit the required assets
     * @param receiver Address to receive minted shares
     * @return Amounts of each asset added
     */
    function rebalanceAndDeposit(address receiver) external override returns (uint256[] memory) {
        require(isRebalanceNeeded(), 'Rebalance not needed');
        (uint256 tVal, uint256[] memory valuations) = _computeTotalValuation();

        uint256[] memory amountsToAdd = _calculateAmountsToAdd(tVal, valuations);
        uint256[] memory amounts = new uint256[](assetInfos.length);
        uint256 totalAddedLiquidity = _calculateTotalAddedLiquidity(amountsToAdd);

        totalAddedLiquidity *= scalingFactor;

        for (uint256 i = 0; i < amountsToAdd.length; i++) {
            if (amountsToAdd[i] > 0) {
                amounts[i] = _calculateLiquidity(i, amountsToAdd[i]);
                IERC20(assetInfos[i].asset).transferFrom(msg.sender, address(this), amountsToAdd[i]);
            }
        }

        _mint(receiver, totalAddedLiquidity);
        _update();

        emit WeightsRebalanced(msg.sender, amountsToAdd);
        return amounts;
    }

    // ============================================
    // WITHDRAW FUNCTION
    // ============================================

    /**
     * @dev Burns fund shares and returns proportional assets to user
     * @param share Amount of shares to burn
     * @param to Address to receive the assets
     * @param deadline Transaction deadline
     * @return The amount of shares burned
     */
    function withdraw(
        uint256 share,
        address to,
        uint256 deadline
    ) external override ensure(deadline) nonReentrant whenNotPaused returns (uint256) {
        require(to != address(0), 'Invalid address');
        require(share > 0, 'Share must be greater than 0');

        uint256 allowance = IERC20(address(this)).allowance(msg.sender, address(this));
        require(allowance >= share, 'Insufficient Allowance');

        bool transferResult = IERC20(address(this)).transferFrom(msg.sender, address(this), share);
        require(transferResult, 'Transfer From Failed');

        uint256 totalSupply = totalSupply();
        require(totalSupply > 0, 'No liquidity');

        address treasury = registry.getTreasury();
        require(treasury != address(0), 'Invalid treasury address');

        uint256[] memory assetShares = calculateAssetShare(share);

        for (uint256 i = 0; i < assetInfos.length; i++) {
            uint256 amountToSend = assetShares[i];
            require(
                IERC20(assetInfos[i].asset).balanceOf(address(this)) >= amountToSend,
                'Insufficient Asset Balance'
            );

            uint256 fee = _haircut(amountToSend);
            amountToSend -= fee;

            bool transferProtocolSuccess = IERC20(assetInfos[i].asset).transfer(treasury, fee);
            require(transferProtocolSuccess, 'Fee Transfer Failed');

            bool transferSuccess = IERC20(assetInfos[i].asset).transfer(to, amountToSend);
            require(transferSuccess, 'Asset transfer failed');
        }

        require(balanceOf(address(this)) >= share, 'Insufficient liquidity');
        _burn(address(this), share);
        _update();

        emit Withdraw(to, share);
        return share;
    }

    /**
     * @dev Calculates proportional asset amounts for a given share
     */
    function calculateAssetShare(uint256 share) public view returns (uint256[] memory) {
        uint256[] memory assetShares = new uint256[](assetInfos.length);
        uint256 totalSupply = totalSupply();

        for (uint256 i = 0; i < assetInfos.length; i++) {
            uint256 assetBalance = IERC20(assetInfos[i].asset).balanceOf(address(this));
            assetShares[i] = (assetBalance * share) / totalSupply;
        }
        return assetShares;
    }

    // ============================================
    // REBALANCE FUNCTIONS
    // ============================================

    /**
     * @dev Public rebalance function - callable by anyone when threshold is exceeded
     */
    function rebalance() external override {
        require(isRebalanceNeeded(), 'Rebalance not needed');
        _performRebalance();
    }

    /**
     * @dev Internal rebalance logic using the external rebalancer
     */
    function _performRebalance() internal {
        address rebalancer = registry.getBaluniRebalancer();
        address[] memory assets = getAssets();
        uint256[] memory weights = getWeights();

        for (uint256 i = 0; i < assetInfos.length; i++) {
            uint256 allowance = IERC20(assetInfos[i].asset).allowance(address(this), rebalancer);
            if (allowance < type(uint256).max) {
                IERC20(assetInfos[i].asset).approve(rebalancer, type(uint256).max);
            }
        }

        uint256[] memory balances = getReserves();
        uint256 rebalance_threshold = registry.getREBALANCE_THRESHOLD();

        IBaluniV1Rebalancer(rebalancer).rebalance(
            balances,
            assets,
            weights,
            rebalance_threshold,
            address(this),
            address(this),
            baseAsset
        );

        _update();
        emit RebalancePerformed(msg.sender, assets);
    }

    /**
     * @dev Checks if rebalancing is needed based on threshold
     */
    function isRebalanceNeeded() public view override returns (bool) {
        uint256 rebalance_threshold = registry.getREBALANCE_THRESHOLD();
        (bool[] memory directions, uint256[] memory deviations) = getDeviations();

        for (uint256 i = 0; i < deviations.length; i++) {
            if (directions[i] && deviations[i] > rebalance_threshold) {
                return true;
            }
        }
        return false;
    }

    // ============================================
    // WEIGHT MANAGEMENT
    // ============================================

    /**
     * @dev Updates the target weights for the fund - owner only
     * @param newWeights Array of new weights (must sum to 10000)
     */
    function setWeights(uint256[] memory newWeights) external override onlyOwner {
        require(newWeights.length == assetInfos.length, 'Invalid weights length');

        uint256 totalWeight = 0;
        for (uint256 i = 0; i < newWeights.length; i++) {
            require(newWeights[i] > 0, 'Weight must be greater than 0');
            totalWeight += newWeights[i];
        }
        require(totalWeight == 10000, 'Weights must sum to 10000');

        for (uint256 i = 0; i < assetInfos.length; i++) {
            assetInfos[i].weight = newWeights[i];
        }

        emit WeightsUpdated(newWeights);
    }

    // ============================================
    // VIEW FUNCTIONS
    // ============================================

    /**
     * @dev Returns deviation of current weights from target weights
     */
    function getDeviations() public view override returns (bool[] memory directions, uint256[] memory deviations) {
        (uint256 totVal, uint256[] memory valuations) = _computeTotalValuation();
        uint256 numAssets = assetInfos.length;

        directions = new bool[](numAssets);
        deviations = new uint256[](numAssets);

        if (totVal == 0) {
            return (directions, deviations);
        }

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
     * @dev Returns the weight of a specific token
     */
    function getTokenWeight(address token) public view override returns (uint256) {
        for (uint256 i = 0; i < assetInfos.length; i++) {
            if (assetInfos[i].asset == token) {
                return assetInfos[i].weight;
            }
        }
        return 0;
    }

    /**
     * @dev Returns liquidity value of a specific asset index
     */
    function assetLiquidity(uint256 assetIndex) external view override returns (uint256) {
        (, uint256[] memory usdValuations) = _computeTotalValuation();
        require(assetIndex < usdValuations.length, 'Invalid asset index');
        return usdValuations[assetIndex];
    }

    /**
     * @dev Returns total valuation and per-asset valuations
     */
    function totalValuation() external view override returns (uint256 totalVal, uint256[] memory valuations) {
        return _computeTotalValuation();
    }

    /**
     * @dev Returns total AUM (Assets Under Management)
     */
    function liquidity() external view override returns (uint256) {
        (uint256 totalVal, ) = _computeTotalValuation();
        return totalVal;
    }

    /**
     * @dev Returns the NAV (Net Asset Value) per share
     */
    function unitPrice() external view override returns (uint256) {
        uint256 baseDecimal = IERC20Metadata(baseAsset).decimals();
        uint256 factor = 10 ** (18 - baseDecimal);
        uint256 supply = totalSupply();

        if (supply == 0) {
            return 0;
        }

        (uint256 tVal, ) = _computeTotalValuation();

        if (tVal == 0) {
            return 0;
        }

        uint256 scaledTotalVal = tVal * factor;
        uint256 unitPriceScaledDown = (scaledTotalVal * ONE) / supply;

        return unitPriceScaledDown;
    }

    /**
     * @dev Returns reserves for all assets
     */
    function getReserves() public view override returns (uint256[] memory) {
        uint256[] memory _reserves = new uint256[](assetInfos.length);

        for (uint256 i = 0; i < assetInfos.length; i++) {
            _reserves[i] = IERC20(assetInfos[i].asset).balanceOf(address(this));
        }

        return _reserves;
    }

    /**
     * @dev Returns reserve for a specific asset
     */
    function getAssetReserve(address asset) public view override returns (uint256) {
        for (uint256 i = 0; i < assetInfos.length; i++) {
            if (asset == assetInfos[i].asset) {
                return IERC20(asset).balanceOf(address(this));
            }
        }
        return 0;
    }

    /**
     * @dev Returns list of all assets in the fund
     */
    function getAssets() public view override returns (address[] memory) {
        address[] memory assets = new address[](assetInfos.length);
        for (uint256 i = 0; i < assetInfos.length; i++) {
            assets[i] = assetInfos[i].asset;
        }
        return assets;
    }

    /**
     * @dev Returns list of all weights
     */
    function getWeights() public view override returns (uint256[] memory) {
        uint256[] memory weights = new uint256[](assetInfos.length);
        for (uint256 i = 0; i < assetInfos.length; i++) {
            weights[i] = assetInfos[i].weight;
        }
        return weights;
    }

    // ============================================
    // INTERNAL FUNCTIONS
    // ============================================

    /**
     * @dev Computes total valuation in base asset terms
     */
    function _computeTotalValuation() internal view returns (uint256 tVal, uint256[] memory valuations) {
        uint256 numAssets = assetInfos.length;
        valuations = new uint256[](numAssets);

        for (uint256 i = 0; i < numAssets; i++) {
            address asset = assetInfos[i].asset;
            uint256 assetReserve = getAssetReserve(asset);

            if (assetReserve == 0) continue;

            if (asset == baseAsset) {
                valuations[i] = assetReserve;
            } else {
                valuations[i] = _convertTokenToBase(asset, assetReserve);
            }
            tVal += valuations[i];
        }

        return (tVal, valuations);
    }

    function _calculateTotalAddedLiquidity(
        uint256[] memory amountsToAdd
    ) internal view returns (uint256 totalAddedLiquidity) {
        for (uint256 i = 0; i < assetInfos.length; i++) {
            totalAddedLiquidity += amountsToAdd[i];
        }
        return totalAddedLiquidity;
    }

    function _calculateAmountsToAdd(
        uint256 tVal,
        uint256[] memory valuations
    ) internal view returns (uint256[] memory amountsToAdd) {
        amountsToAdd = new uint256[](assetInfos.length);
        for (uint256 i = 0; i < assetInfos.length; i++) {
            uint256 targetValuation = (tVal * assetInfos[i].weight) / 10000;
            if (valuations[i] < targetValuation) {
                amountsToAdd[i] = targetValuation - valuations[i];
            }
        }
        return amountsToAdd;
    }

    function _calculateLiquidity(uint256 index, uint256 amountToAdd) internal view returns (uint256) {
        if (assetInfos[index].asset == baseAsset) return amountToAdd;
        uint256 tokenAmount = _convertBaseToToken(assetInfos[index].asset, amountToAdd);
        require(tokenAmount > 0, 'Invalid token amount to add');
        return tokenAmount;
    }

    function _convertBaseToToken(address toToken, uint256 amount) internal view returns (uint256) {
        IBaluniV1Oracle baluniOracle = IBaluniV1Oracle(registry.getBaluniOracle());
        return baluniOracle.convert(baseAsset, toToken, amount);
    }

    function _convertTokenToBase(address fromToken, uint256 amount) internal view returns (uint256) {
        IBaluniV1Oracle baluniOracle = IBaluniV1Oracle(registry.getBaluniOracle());
        return baluniOracle.convert(fromToken, baseAsset, amount);
    }

    function _haircut(uint256 amount) internal view returns (uint256) {
        uint256 _BPS_FEE = registry.getBPS_FEE();
        uint256 _BPS_BASE = registry.getBPS_BASE();
        return (amount * _BPS_FEE) / _BPS_BASE;
    }

    function _isValidAsset(address token) internal view returns (bool) {
        for (uint256 i = 0; i < assetInfos.length; i++) {
            if (assetInfos[i].asset == token) {
                return true;
            }
        }
        return false;
    }

    function _update() internal {
        for (uint256 i = 0; i < assetInfos.length; i++) {
            assetInfos[i].reserve = IERC20(assetInfos[i].asset).balanceOf(address(this));
        }
    }

    // ============================================
    // ADMIN FUNCTIONS
    // ============================================

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
