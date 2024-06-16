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
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '../interfaces/I1inchSpotAgg.sol';
import '../interfaces/IBaluniV1Registry.sol';
import '../interfaces/IBaluniV1Oracle.sol';
import '../interfaces/IStaticOracle.sol';

contract BaluniV1Oracle is Initializable, OwnableUpgradeable, UUPSUpgradeable, IBaluniV1Oracle {
    IBaluniV1Registry public registry;

    function initialize(address _registry) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        registry = IBaluniV1Registry(_registry);
    }

    function reinitialize(address _registry, uint64 version) public reinitializer(version) {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        registry = IBaluniV1Registry(_registry);
    }

    /**
     * @dev Converts the specified amount of `fromToken` to `toToken` using the available oracle.
     * If the conversion fails with the static oracle, it falls back to the aggregator oracle.
     * @param fromToken The address of the token to convert from.
     * @param toToken The address of the token to convert to.
     * @param amount The amount of `fromToken` to convert.
     * @return valuation The converted valuation of `amount` in `toToken`.
     */
    function convert(
        address fromToken,
        address toToken,
        uint256 amount
    ) public view override returns (uint256 valuation) {
        return this.convertWithStaticOracle(fromToken, toToken, amount);

        // try this.convertWithStaticOracle(fromToken, toToken, amount) returns (uint256 _valuation) {
        //     return _valuation;
        // } catch {
        //     return this.convertWithAgg(fromToken, toToken, amount);
        // }
    }

    /**
     * @dev Converts the specified amount of `fromToken` to `toToken` using the available oracle.
     * If the conversion fails with the static oracle, it falls back to the aggregator oracle.
     * This function is externally callable.
     * @param fromToken The address of the token to convert from.
     * @param toToken The address of the token to convert to.
     * @param amount The amount of `fromToken` to convert.
     * @return valuation The converted valuation of `amount` in `toToken`.
     */
    function convertScaled(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view override returns (uint256 valuation) {
        return this.convertScaledWithStaticOracle(fromToken, toToken, amount);

        // try this.convertScaledWithStaticOracle(fromToken, toToken, amount) returns (uint256 _valuation) {
        //     return _valuation;
        // } catch {
        //     return this.convertScaledWithAgg(fromToken, toToken, amount);
        // }
    }

    /**
     * @dev Converts the specified amount of `fromToken` to `toToken` using the 1inch aggregator.
     * @param fromToken The address of the token to convert from.
     * @param toToken The address of the token to convert to.
     * @param amount The amount of `fromToken` to convert.
     * @return valuation The converted valuation of `amount` in `toToken`.
     */
    function convertWithAgg(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view returns (uint256 valuation) {
        // if (fromToken == toToken) return amount;
        // address _1InchSpotAgg = registry.get1inchSpotAgg();
        // uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
        // uint8 toDecimal = IERC20Metadata(toToken).decimals();
        // uint256 rate = I1inchSpotAgg(_1InchSpotAgg).getRate(IERC20(fromToken), IERC20(toToken), false);
        // rate = (rate * (10 ** fromDecimal)) / (10 ** toDecimal);
        // uint256 factor;
        // if (fromDecimal >= toDecimal) {
        //     factor = 10 ** (fromDecimal - toDecimal);
        //     valuation = ((amount / factor) * rate) / 1e18;
        // } else {
        //     factor = 10 ** (toDecimal - fromDecimal);
        //     valuation = ((amount * factor) * rate) / 1e18;
        // }
        // return valuation;
    }

    /**
     * @dev Converts the specified amount of `fromToken` to `toToken` using the 1inch aggregator and scales the result.
     * @param fromToken The address of the token to convert from.
     * @param toToken The address of the token to convert to.
     * @param amount The amount of `fromToken` to convert.
     * @return valuation  The scaled converted valuation of `amount` in `toToken`.
     */
    function convertScaledWithAgg(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view returns (uint256 valuation) {
        // if (fromToken == toToken) return amount * 10 ** (18 - IERC20Metadata(toToken).decimals());
        // address _1InchSpotAgg = registry.get1inchSpotAgg();
        // uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
        // uint8 toDecimal = IERC20Metadata(toToken).decimals();
        // uint256 rate = I1inchSpotAgg(_1InchSpotAgg).getRate(IERC20(fromToken), IERC20(toToken), false);
        // rate = (rate * (10 ** fromDecimal)) / (10 ** toDecimal);
        // uint256 scalingFactor;
        // uint256 tokenAmount;
        // uint256 finalScalingFactor = 10 ** (18 - toDecimal);
        // if (fromDecimal == toDecimal) {
        //     valuation = (amount * rate) / 1e18;
        // } else if (fromDecimal > toDecimal) {
        //     scalingFactor = 10 ** (fromDecimal - toDecimal);
        //     tokenAmount = amount / scalingFactor;
        //     valuation = (tokenAmount * rate) / 1e18;
        // } else {
        //     scalingFactor = 10 ** (toDecimal - fromDecimal);
        //     tokenAmount = amount * scalingFactor;
        //     valuation = (tokenAmount * rate) / 1e18;
        // }
        // valuation = valuation * finalScalingFactor;
        // return valuation;
    }

    /**
     * @dev Converts the specified amount of `fromToken` to `toToken` using the static oracle.
     * @param fromToken The address of the token to convert from.
     * @param toToken The address of the token to convert to.
     * @param amount The amount of `fromToken` to convert.
     * @return  valuation of the converted amount.
     */
    function convertWithStaticOracle(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view returns (uint256 valuation) {
        IStaticOracle staticOracle = IStaticOracle(registry.getStaticOracle());
        require(address(staticOracle) != address(0), 'StaticOracle not set');
        (valuation, ) = staticOracle.quoteAllAvailablePoolsWithTimePeriod(uint128(amount), fromToken, toToken, 3600);
        return valuation;
    }

    /**
     * @dev Converts the given amount of tokens from one token to another using a static oracle.
     * @param fromToken The address of the token to convert from.
     * @param toToken The address of the token to convert to.
     * @param amount The amount of tokens to convert.
     * @return  valuation of the converted tokens.
     */
    function convertScaledWithStaticOracle(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view returns (uint256 valuation) {
        uint256 _valuation = this.convertWithStaticOracle(fromToken, toToken, amount);
        valuation = scaleUp(_valuation, IERC20Metadata(toToken).decimals());
        return valuation;
    }

    /**
     * @dev Scales up the given amount by subtracting the decimals.
     * @param amount The amount to be scaled up.
     * @param decimals The number of decimals to be subtracted.
     * @return The scaled up amount.
     */
    function scaleUp(uint256 amount, uint256 decimals) internal pure returns (uint256) {
        return amount * (10 ** (18 - decimals));
    }

    /**
     * @dev Scales down the given amount by dividing it by the difference between 10^18 and the decimals.
     * @param amount The amount to be scaled down.
     * @param decimals The number of decimals to be subtracted.
     * @return The scaled down amount.
     */
    function scaleDown(uint256 amount, uint256 decimals) internal pure returns (uint256) {
        return amount / (10 ** (18 - decimals));
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
