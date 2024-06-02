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

import './interfaces/I1inchSpotAgg.sol';
import './interfaces/IBaluniV1Registry.sol';
import './interfaces/IBaluniV1Oracle.sol';
import './interfaces/IStaticOracle.sol';

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

    function convertWithAgg(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view returns (uint256 valuation) {
        uint256 rate;
        address _1InchSpotAgg = registry.get1inchSpotAgg();
        uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
        uint8 toDecimal = IERC20Metadata(toToken).decimals();
        uint256 numerator = 10 ** fromDecimal;
        uint256 denominator = 10 ** toDecimal;

        if (fromToken == toToken) return amount;

        rate = I1inchSpotAgg(_1InchSpotAgg).getRate(IERC20(fromToken), IERC20(toToken), false);
        rate = (rate * numerator) / denominator; // scaled to 18 decimal

        uint256 factor;
        uint256 tokenAmount;

        if (fromDecimal == toDecimal) {
            valuation = (amount * rate) / 1e18; // toDecimal
            return valuation;
        }

        if (fromDecimal >= toDecimal) {
            factor = 10 ** (fromDecimal - toDecimal);
            tokenAmount = amount / factor; // scaled to correct decimal
            valuation = (tokenAmount * rate) / 1e18; // 18 decimal
        } else {
            factor = 10 ** (toDecimal - fromDecimal);
            tokenAmount = amount * factor; // scaled to correct decimal
            valuation = (tokenAmount * rate) / 1e18; // 18 decimal
        }

        return valuation;
    }

    function convertScaledWithAgg(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view returns (uint256 valuation) {
        uint256 rate;
        address _1InchSpotAgg = registry.get1inchSpotAgg();
        uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
        uint8 toDecimal = IERC20Metadata(toToken).decimals();
        uint256 numerator = 10 ** fromDecimal;
        uint256 denominator = 10 ** toDecimal;

        if (fromToken == toToken) return amount * 10 ** (18 - toDecimal);

        rate = I1inchSpotAgg(_1InchSpotAgg).getRate(IERC20(fromToken), IERC20(toToken), false);
        rate = (rate * numerator) / denominator; // scaled to 18 decimal

        uint256 scalingFactor;
        uint256 tokenAmount;

        uint256 finalScalingFactor = 10 ** (18 - toDecimal);

        if (fromDecimal == toDecimal) {
            valuation = (amount * rate) / 1e18; // toDecimal
            valuation = valuation * finalScalingFactor;
            return valuation;
        }

        if (fromDecimal >= toDecimal) {
            scalingFactor = 10 ** (fromDecimal - toDecimal);
            tokenAmount = amount / scalingFactor; // scaled to correct decimal
            valuation = (tokenAmount * rate) / 1e18; // 18 decimal
        } else {
            scalingFactor = 10 ** (toDecimal - fromDecimal);
            tokenAmount = amount * scalingFactor; // scaled to correct decimal
            valuation = (tokenAmount * rate) / 1e18; // 18 decimal
        }

        valuation = valuation * finalScalingFactor;

        return valuation;
    }

    function convert(
        address fromToken,
        address toToken,
        uint256 amount
    ) public view override returns (uint256 valuation) {
        IStaticOracle staticOracle = IStaticOracle(registry.getStaticOracle());
        require(address(staticOracle) != address(0), 'StaticOracle not set');
        (valuation, ) = staticOracle.quoteAllAvailablePoolsWithTimePeriod(uint128(amount), fromToken, toToken, 3600);
        return valuation;
    }

    function convertScaled(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view override returns (uint256 valuation) {
        uint256 rate;
        uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
        uint8 toDecimal = IERC20Metadata(toToken).decimals();

        uint256 numerator = 10 ** fromDecimal;
        uint256 denominator = 10 ** toDecimal;

        if (fromToken == toToken) return amount * 10 ** (18 - toDecimal);

        rate = convert(fromToken, toToken, 1 * 10 ** fromDecimal);
        rate = (rate * numerator) / denominator; // scaled to 18 decimal

        uint256 scalingFactor;
        uint256 tokenAmount;

        uint256 finalScalingFactor = 10 ** (18 - toDecimal);

        if (fromDecimal == toDecimal) {
            valuation = (amount * rate) / 10 ** (toDecimal); // toDecimal
            valuation = valuation * finalScalingFactor;
            return valuation;
        }

        if (fromDecimal >= toDecimal) {
            scalingFactor = 10 ** (fromDecimal - toDecimal);
            tokenAmount = amount / scalingFactor; // scaled to correct decimal
            valuation = (tokenAmount * rate) / 1e18; // 18 decimal
        } else {
            scalingFactor = 10 ** (toDecimal - fromDecimal);
            tokenAmount = amount * scalingFactor; // scaled to correct decimal
            valuation = (tokenAmount * rate) / 1e18; // 18 decimal
        }

        valuation = valuation * finalScalingFactor;

        return valuation;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
