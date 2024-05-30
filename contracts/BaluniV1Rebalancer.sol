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
import './interfaces/IBaluniV1Rebalancer.sol';
import './interfaces/I1inchSpotAgg.sol';
import './BaluniV1Uniswapper.sol';

contract BaluniV1Rebalancer is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    IBaluniV1Rebalancer,
    BaluniV1Uniswapper
{
    IBaluniV1Registry public registry;

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
    ) external override {
        address USDC = registry.getUSDC();
        address WNATIVE = registry.getWNATIVE();
        address baluniRouter = registry.getBaluniRouter();
        address treasury = registry.getTreasury();

        RebalanceVars memory vars = _checkRebalance(balances, assets, weights, limit, sender, baseAsset);

        for (uint256 i = 0; i < vars.overweightVaults.length; i++) {
            if (vars.overweightAmounts[i] > 0) {
                address asset = assets[vars.overweightVaults[i]];
                require(vars.balances[i] >= vars.overweightAmounts[i], 'Balance under overweight amounts');
                IERC20(asset).transferFrom(sender, address(this), vars.overweightAmounts[i]);

                if (asset == address(USDC)) {
                    continue;
                }

                if (asset == address(WNATIVE)) {
                    vars.amountOut += _singleSwap(asset, address(USDC), vars.overweightAmounts[i], address(this));
                } else {
                    vars.amountOut += _multiHopSwap(
                        asset,
                        address(WNATIVE),
                        address(USDC),
                        vars.overweightAmounts[i],
                        address(this)
                    );
                }
            }
        }

        uint256 usdBalance = IERC20(USDC).balanceOf(address(this));
        require(usdBalance >= vars.amountOut, 'Insufficient USDC Balance');

        for (uint256 i = 0; i < vars.underweightVaults.length; i++) {
            if (vars.underweightAmounts[i] > 0) {
                address asset = assets[vars.underweightVaults[i]];
                uint256 rebaseActiveWgt = (vars.underweightAmounts[i] * 10000) / vars.totalActiveWeight;
                uint256 rebBuyQty = (rebaseActiveWgt * usdBalance * 1e12) / 10000;

                if (asset == address(USDC)) {
                    IERC20(USDC).transfer(receiver, rebBuyQty / 1e12);
                    continue;
                }

                if (rebBuyQty > 0 && rebBuyQty <= usdBalance * 1e12) {
                    require(usdBalance >= rebBuyQty / 1e12, 'Balance under RebuyQty');

                    uint256 amountOut;
                    if (asset == address(WNATIVE)) {
                        amountOut = _singleSwap(address(USDC), address(WNATIVE), rebBuyQty / 1e12, address(this));
                    } else {
                        amountOut = _multiHopSwap(
                            address(USDC),
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

                    IERC20(asset).transfer(address(receiver), amountToReceiver);
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
    ) public view override returns (RebalanceVars memory) {
        return _checkRebalance(balances, assets, weights, limit, sender, baseAsset);
    }

    /**
     * @dev Internal function to check if rebalancing is required based on the given parameters.
     * @param balances An array of token balances.
     * @param assets An array of token addresses.
     * @param weights An array of target weights for each token.
     * @param limit The maximum allowed deviation from the target weight.
     * @param sender The address of the sender.
     * @param baseAsset The address of the base asset.
     * @return rebalanceVars A struct containing rebalance variables.
     */
    function _checkRebalance(
        uint256[] memory balances,
        address[] calldata assets,
        uint256[] calldata weights,
        uint256 limit,
        address sender,
        address baseAsset
    ) internal view returns (RebalanceVars memory) {
        address baluniRouter = registry.getBaluniRouter();

        if (balances.length == 0) {
            for (uint256 i = 0; i < assets.length; i++) {
                balances[i] = IERC20(assets[i]).balanceOf(sender);
            }
        }

        uint256 totalValue = calculateTotalValue(assets, sender);
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

        vars.balances = balances;

        for (uint256 i = 0; i < assets.length; i++) {
            //vars.balances[i] = balances[i];
            uint256 decimals = IERC20Metadata(assets[i]).decimals();
            uint256 tokensTotalValue;

            uint256 price = IBaluniV1Router(baluniRouter).tokenValuation(1 * 10 ** decimals, assets[i]);

            if (assets[i] == address(baseAsset)) {
                uint256 baseAssetDecimals = IERC20Metadata(baseAsset).decimals();
                uint256 factor = 10 ** (18 - baseAssetDecimals);
                tokensTotalValue = vars.balances[i] * factor;
            } else {
                tokensTotalValue = convert(assets[i], baseAsset, vars.balances[i]);
            }

            uint256 targetWeight = weights[i];
            uint256 currentWeight = (tokensTotalValue * 10000) / totalValue;
            bool overweight = currentWeight > targetWeight;
            uint256 overweightPercent = overweight ? currentWeight - targetWeight : targetWeight - currentWeight;

            if (overweight && overweightPercent > limit) {
                uint256 overweightAmount = (overweightPercent * totalValue) / 10000;
                vars.finalUsdBalance += overweightAmount;

                overweightAmount = (overweightAmount * 1e18) / price;
                overweightAmount = overweightAmount / (10 ** (18 - decimals));
                vars.overweightVaults[vars.overweightVaultsLength] = i;
                vars.overweightAmounts[vars.overweightVaultsLength] = overweightAmount;
                vars.overweightVaultsLength++;
            } else if (!overweight && overweightPercent > limit) {
                vars.totalActiveWeight += overweightPercent;
                vars.underweightVaults[vars.underweightVaultsLength] = i;
                vars.underweightAmounts[vars.underweightVaultsLength] = overweightPercent;
                vars.underweightVaultsLength++;
            }
        }

        vars.overweightVaults = _resize(vars.overweightVaults, vars.overweightVaultsLength);
        vars.overweightAmounts = _resize(vars.overweightAmounts, vars.overweightVaultsLength);
        vars.underweightVaults = _resize(vars.underweightVaults, vars.underweightVaultsLength);
        vars.underweightAmounts = _resize(vars.underweightAmounts, vars.underweightVaultsLength);

        return vars;
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
    function calculateTotalValue(address[] memory assets, address user) private view returns (uint256) {
        address USDC = registry.getUSDC();
        address baluniRouter = registry.getBaluniRouter();

        uint256 _tokenValue = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 balance = IERC20(assets[i]).balanceOf(user);

            if (assets[i] == address(USDC)) {
                _tokenValue += balance * 1e12;
            } else {
                _tokenValue += IBaluniV1Router(baluniRouter).tokenValuation(balance, assets[i]);
            }
        }

        return _tokenValue;
    }

    /**
     * @dev Converts an amount of tokens from one token to another based on the current exchange rate.
     * @param fromToken The address of the token to convert from.
     * @param toToken The address of the token to convert to.
     * @param amount The amount of tokens to convert.
     * @return The converted amount of tokens.
     */
    function convert(address fromToken, address toToken, uint256 amount) public view returns (uint256) {
        uint256 rate;
        address _1InchSpotAgg = registry.get1inchSpotAgg();
        uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
        uint8 toDecimal = IERC20Metadata(toToken).decimals();
        uint256 numerator = 10 ** fromDecimal;
        uint256 denominator = 10 ** toDecimal;

        rate = I1inchSpotAgg(_1InchSpotAgg).getRate(IERC20(fromToken), IERC20(toToken), false);
        rate = (rate * numerator) / denominator;

        uint256 tokenAmount = ((amount * rate) / 10 ** 18);

        if (fromDecimal == toDecimal) {
            tokenAmount = ((amount * rate) / 10 ** 18);
            return tokenAmount;
        }

        uint256 factor = 10 ** (fromDecimal > toDecimal ? fromDecimal - toDecimal : toDecimal - fromDecimal);

        if (fromDecimal > toDecimal) {
            tokenAmount /= factor;
        } else {
            tokenAmount *= factor;
        }

        return tokenAmount;
    }
}
