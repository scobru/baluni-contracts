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
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import './interfaces/IBaluniV1Router.sol';
import './interfaces/IBaluniV1Swapper.sol';
import './interfaces/IBaluniV1Registry.sol';
import './interfaces/IBaluniV1Oracle.sol';

contract BaluniV1Rebalancer is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IBaluniV1Registry public registry;

    struct RebalanceVars {
        uint256 length;
        uint256 totalValue;
        uint256 finalUsdBalance;
        uint256 overweightVaultsLength;
        uint256 underweightVaultsLength;
        uint256 totalActiveWeight;
        uint256 amountOut;
        uint256[] overweightVaults;
        uint256[] overweightAmounts;
        uint256[] underweightVaults;
        uint256[] underweightAmounts;
        uint256[] balances;
    }

    function initialize(address _registry) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(msg.sender);
        registry = IBaluniV1Registry(_registry);
    }

    function reinitialize(address _registry, uint64 version) public reinitializer(version) {
        registry = IBaluniV1Registry(_registry);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Rebalances the portfolio by buying and selling assets based on their weights.
     * @param balances An array of current asset balances.
     * @param assets An array of asset addresses.
     * @param weights An array of asset weights.
     * @param limit The maximum amount of assets to be rebalanced.
     * @param sender The address from which the assets will be transferred.
     * @param receiver The address to which the assets will be transferred.
     * @param baseAsset The base asset used for rebalancing.
     */
    function rebalance(
        uint256[] memory balances,
        address[] calldata assets,
        uint256[] calldata weights,
        uint256 limit,
        address sender,
        address receiver,
        address baseAsset
    ) external {
        address USDC = registry.getUSDC();
        address WNATIVE = registry.getWNATIVE();

        if (balances.length == 0) {
            for (uint256 i = 0; i < assets.length; i++) {
                balances[i] = IERC20(assets[i]).balanceOf(sender);
            }
        }

        RebalanceVars memory vars = _checkRebalance(balances, assets, weights, limit, baseAsset);

        for (uint256 i = 0; i < vars.overweightVaults.length; i++) {
            if (vars.overweightAmounts[i] > 0) {
                address asset = assets[vars.overweightVaults[i]];
                require(vars.balances[i] >= vars.overweightAmounts[i], 'Under Overweight Amount');

                // check aallowance
                uint256 allowance = IERC20(asset).allowance(sender, address(this));
                require(allowance >= vars.overweightAmounts[i], 'Allowance under Overweight Amount');

                IERC20(asset).transferFrom(sender, address(this), vars.overweightAmounts[i]);

                if (asset == baseAsset) {
                    continue;
                }

                address baluniSwapper = registry.getBaluniSwapper();
                IERC20(asset).approve(baluniSwapper, vars.overweightAmounts[i]);

                if (asset == address(WNATIVE)) {
                    vars.amountOut += IBaluniV1Swapper(baluniSwapper).singleSwap(
                        asset,
                        baseAsset,
                        vars.overweightAmounts[i],
                        address(this)
                    );
                } else {
                    vars.amountOut += IBaluniV1Swapper(baluniSwapper).multiHopSwap(
                        asset,
                        address(WNATIVE),
                        baseAsset,
                        vars.overweightAmounts[i],
                        address(this)
                    );
                }
            }
        }

        uint256 usdBalance = IERC20(USDC).balanceOf(address(this));
        require(usdBalance >= vars.amountOut, 'Insufficient USDC Balance');

        address _receiver = receiver;

        address[] memory _assets = assets;

        for (uint256 i = 0; i < vars.underweightVaults.length; i++) {
            if (vars.underweightAmounts[i] > 0) {
                address asset = _assets[vars.underweightVaults[i]];
                uint256 rebaseActiveWgt = (vars.underweightAmounts[i] * 10000) / vars.totalActiveWeight;
                uint256 rebBuyQty = (rebaseActiveWgt * usdBalance * 1e12) / 10000;

                if (asset == baseAsset) {
                    IERC20(USDC).transfer(_receiver, rebBuyQty / 1e12);
                    continue;
                }

                if (rebBuyQty > 0 && rebBuyQty <= usdBalance * 1e12) {
                    require(usdBalance >= rebBuyQty / 1e12, 'Balance under RebuyQty');

                    address baluniSwapper = registry.getBaluniSwapper();
                    IERC20(baseAsset).approve(baluniSwapper, rebBuyQty / 1e12);

                    uint256 amountOut;
                    if (asset == address(WNATIVE)) {
                        amountOut = IBaluniV1Swapper(baluniSwapper).singleSwap(
                            baseAsset,
                            asset,
                            rebBuyQty / 1e12,
                            address(this)
                        );
                    } else {
                        amountOut = IBaluniV1Swapper(baluniSwapper).multiHopSwap(
                            baseAsset,
                            address(WNATIVE),
                            asset,
                            rebBuyQty / 1e12,
                            address(this)
                        );
                    }

                    vars.amountOut = amountOut;
                    uint256 amountToReceiver = calculateNetAmountAfterFee(amountOut);
                    uint256 remainingToReceiver = amountOut - amountToReceiver;
                    uint256 amountToRouter = calculateNetAmountAfterFee(remainingToReceiver);
                    uint256 amountToTreasury = remainingToReceiver - amountToRouter;

                    require(
                        IERC20(asset).balanceOf(address(this)) >= amountToReceiver,
                        'Balance under amountToTransfer'
                    );
                    address baluniRouter = registry.getBaluniRouter();
                    address treasury = registry.getTreasury();

                    IERC20(asset).transfer(address(_receiver), amountToReceiver);
                    IERC20(asset).transfer(address(baluniRouter), amountToRouter);
                    IERC20(asset).transfer(address(treasury), amountToTreasury);
                }
            }
        }
    }

    /**
     * @dev Checks if a rebalance is needed based on the given parameters.
     * @param balances An array of token balances.
     * @param assets An array of token addresses.
     * @param weights An array of token weights.
     * @param limit The maximum allowed difference between the current and target weights.
     * @param sender The address of the caller.
     * @param baseAsset The address of the base asset.
     * @return A struct containing the rebalance variables.
     */
    function checkRebalance(
        uint256[] memory balances,
        address[] calldata assets,
        uint256[] calldata weights,
        uint256 limit,
        address sender,
        address baseAsset
    ) public view returns (RebalanceVars memory) {
        uint256[] memory _balances = new uint256[](assets.length);
        if (balances.length == 0) {
            for (uint256 i = 0; i < assets.length; i++) {
                _balances[i] = IERC20(assets[i]).balanceOf(sender);
            }
        } else {
            _balances = balances;
        }
        return _checkRebalance(_balances, assets, weights, limit, baseAsset);
    }

    /**
     * @dev Internal function to check if rebalancing is required based on the given parameters.
     * @param balances An array of token balances.
     * @param assets An array of token addresses.
     * @param weights An array of target weights for each token.
     * @param limit The maximum allowed deviation from the target weight.
     * @param baseAsset The address of the base asset.
     * @return rebalanceVars A struct containing rebalance variables.
     */
    function _checkRebalance(
        uint256[] memory balances,
        address[] calldata assets,
        uint256[] calldata weights,
        uint256 limit,
        address baseAsset
    ) internal view returns (RebalanceVars memory) {
        uint256 totalValue = calculateTotalValue(balances, assets, baseAsset);

        RebalanceVars memory vars = RebalanceVars(
            assets.length,
            totalValue,
            0,
            0,
            0,
            0,
            0,
            new uint256[](assets.length * 2),
            new uint256[](assets.length * 2),
            new uint256[](assets.length * 2),
            new uint256[](assets.length * 2),
            new uint256[](assets.length)
        );

        // STACK TO DEEP reassignment
        address[] memory _assets = assets;
        uint256[] memory _weights = weights;
        uint256 _limit = limit;
        address _baseAsset = baseAsset;
        uint256 _totalValue = totalValue;

        RebalanceVars memory _vars = vars;

        _vars.balances = balances;

        for (uint256 i = 0; i < _assets.length; i++) {
            uint256 decimals = IERC20Metadata(_assets[i]).decimals();
            uint256 tokensTotalValue;

            uint256 baseAssetDecimals = IERC20Metadata(_baseAsset).decimals();
            uint256 factor = 10 ** (18 - baseAssetDecimals);

            IBaluniV1Oracle baluniOracle = IBaluniV1Oracle(registry.getBaluniOracle());

            uint256 priceScaled = baluniOracle.convertScaled(_assets[i], _baseAsset, 1 * 10 ** decimals);

            if (_assets[i] == address(_baseAsset)) {
                tokensTotalValue = _vars.balances[i] * factor;
            } else {
                tokensTotalValue = baluniOracle.convertScaled(_assets[i], _baseAsset, _vars.balances[i]);
            }

            uint256 targetWeight = _weights[i];
            uint256 currentWeight = (tokensTotalValue * 10000) / _totalValue;
            bool overweight = currentWeight > targetWeight;
            uint256 overweightPercent = overweight ? currentWeight - targetWeight : targetWeight - currentWeight;

            if (overweight && overweightPercent > _limit) {
                uint256 overweightAmount = (overweightPercent * _totalValue) / 10000;
                _vars.finalUsdBalance += overweightAmount;

                overweightAmount = (overweightAmount * 1e18) / priceScaled;
                overweightAmount = overweightAmount / (10 ** (18 - decimals));
                _vars.overweightVaults[_vars.overweightVaultsLength] = i;
                _vars.overweightAmounts[_vars.overweightVaultsLength] = overweightAmount;
                _vars.overweightVaultsLength++;
            } else if (!overweight && overweightPercent > _limit) {
                _vars.totalActiveWeight += overweightPercent;
                _vars.underweightVaults[_vars.underweightVaultsLength] = i;
                _vars.underweightAmounts[_vars.underweightVaultsLength] = overweightPercent;
                _vars.underweightVaultsLength++;
            }
        }

        _vars.overweightVaults = _resize(_vars.overweightVaults, _vars.overweightVaultsLength);
        _vars.overweightAmounts = _resize(_vars.overweightAmounts, _vars.overweightVaultsLength);
        _vars.underweightVaults = _resize(_vars.underweightVaults, _vars.underweightVaultsLength);
        _vars.underweightAmounts = _resize(_vars.underweightAmounts, _vars.underweightVaultsLength);

        return _vars;
    }

    /**
     * @dev Resizes an array to a specified size.
     * @param arr The original array to be resized.
     * @param size The new size for the array.
     * @return ret The resized array.
     */
    function _resize(uint256[] memory arr, uint256 size) internal pure returns (uint256[] memory) {
        uint256[] memory ret = new uint256[](size);
        for (uint256 i; i < size; i++) {
            ret[i] = arr[i];
        }
        return ret;
    }

    /**
     * @dev Calculates the net amount after applying a fee.
     * @param _amount The initial amount before the fee is applied.
     * @return The net amount after the fee has been applied.
     *
     * The function uses the Basis Point (BPS) system for fee calculation.
     * 1 BPS is 1/100 of a percent or 0.01% hence the BPS base is 10000.
     * The function retrieves the BPS fee from the baluniRouter and calculates the net amount.
     * The fee is subtracted from the BPS base and the result is multiplied with the initial amount.
     * The product is then divided by the BPS base to get the net amount.
     */
    function calculateNetAmountAfterFee(uint256 _amount) internal view returns (uint256) {
        uint256 _BPS_BASE = registry.getBPS_BASE();
        uint256 _BPS_FEE = registry.getBPS_FEE();
        uint256 amountInWithFee = (_amount * (_BPS_BASE - (_BPS_FEE))) / _BPS_BASE;
        return amountInWithFee;
    }

    /**
     * @dev Calculates the total value of the assets held by the caller.
     * @param assets An array of asset addresses.
     * @return The total value of the assets held by the caller.
     */
    function calculateTotalValue(
        uint256[] memory balances,
        address[] memory assets,
        address baseAsset
    ) private view returns (uint256) {
        address USDC = registry.getUSDC();
        uint8 baseDecimal = IERC20Metadata(baseAsset).decimals();
        uint256 factor = 10 ** (18 - baseDecimal);
        IBaluniV1Oracle baluniOracle = IBaluniV1Oracle(registry.getBaluniOracle());

        uint256 _tokenValue = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            if (assets[i] == address(USDC)) {
                _tokenValue += balances[i];
            } else {
                _tokenValue += baluniOracle.convertScaled(assets[i], baseAsset, balances[i]);
            }
        }

        return _tokenValue;
    }
}
