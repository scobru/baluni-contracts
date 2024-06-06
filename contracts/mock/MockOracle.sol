// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import '../interfaces/IBaluniV1Oracle.sol';

contract MockOracle is IBaluniV1Oracle {
    mapping(address => mapping(address => uint256)) public rates;

    // Hardcoded rates
    uint256 public constant USDC_TO_WETH_RATE = 256897185735855109411507118;
    uint256 public constant USDC_TO_USDT_RATE = 1000983989838925640;
    uint256 public constant USDC_TO_WBTC_RATE = 1463657468947761;
    uint256 public constant USDC_TO_WMATIC_RATE = 1351148249095651365340914098616;

    uint256 public constant WMATIC_TO_USDT_RATE = 747767;
    uint256 public constant WMATIC_TO_USDC_RATE = 733905;
    uint256 public constant WMATIC_TO_WBTC_RATE = 1080;
    uint256 public constant WMATIC_TO_WETH_RATE = 189625582664100;

    uint256 public constant WBTC_TO_WMATIC_RATE = 924778033538811846038762973579739;
    uint256 public constant WBTC_TO_USDT_RATE = 681360233243484009138;
    uint256 public constant WBTC_TO_WETH_RATE = 175476470939493533556108593598;
    uint256 public constant WBTC_TO_USDC_RATE = 683003374554512029990;

    uint256 public constant USDT_TO_WBTC_RATE = 1457844841452943;
    uint256 public constant USDT_TO_USDC_RATE = 998840977600189233;
    uint256 public constant USDT_TO_WETH_RATE = 256884484348670192973112135;
    uint256 public constant USDT_TO_WMATIC_RATE = 1351542478738482785523886658083;

    uint256 public constant WETH_TO_WMATIC_RATE = 5273576410685072782753;
    uint256 public constant WETH_TO_USDC_RATE = 3781382154;
    uint256 public constant WETH_TO_USDT_RATE = 3749163887;
    uint256 public constant WETH_TO_WBTC_RATE = 5561821;

    address public USDC;
    address public WNATIVE;

    address public treasury;

    constructor(address usdt, address _usdc, address _wmatic, address weth, address wbtc) {
        WNATIVE = _wmatic;
        USDC = _usdc;
        treasury = msg.sender;

        rates[usdt][USDC] = USDT_TO_USDC_RATE;
        rates[usdt][WNATIVE] = USDT_TO_WMATIC_RATE;
        rates[usdt][wbtc] = USDT_TO_WBTC_RATE;
        rates[usdt][weth] = USDT_TO_WETH_RATE;

        rates[wbtc][usdt] = WBTC_TO_USDT_RATE;
        rates[wbtc][WNATIVE] = WBTC_TO_WMATIC_RATE;
        rates[wbtc][USDC] = WBTC_TO_USDC_RATE;
        rates[wbtc][weth] = WBTC_TO_WETH_RATE;

        rates[USDC][usdt] = USDC_TO_USDT_RATE;
        rates[USDC][wbtc] = USDC_TO_WBTC_RATE;
        rates[USDC][WNATIVE] = USDC_TO_WMATIC_RATE;
        rates[USDC][weth] = USDC_TO_WETH_RATE;

        rates[WNATIVE][wbtc] = WMATIC_TO_WBTC_RATE;
        rates[WNATIVE][weth] = WMATIC_TO_WETH_RATE;
        rates[WNATIVE][USDC] = WMATIC_TO_USDC_RATE;
        rates[WNATIVE][usdt] = WMATIC_TO_USDT_RATE;

        rates[weth][WNATIVE] = WETH_TO_WMATIC_RATE;
        rates[weth][USDC] = WETH_TO_USDC_RATE;
        rates[weth][usdt] = WETH_TO_USDC_RATE;
        rates[weth][wbtc] = WETH_TO_WBTC_RATE;
    }
    /**
     * @dev Converts an amount of tokens from one token to another based on the current exchange rate.
     * @param fromToken The address of the token to convert from.
     * @param toToken The address of the token to convert to.
     * @param amount The amount of tokens to convert.
     * @return valuation The converted amount of tokens.
     */
    function convert(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view override returns (uint256 valuation) {
        uint256 rate;

        uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
        uint8 toDecimal = IERC20Metadata(toToken).decimals();

        rate = rates[address(fromToken)][address(toToken)];
        rate = (rate * (10 ** fromDecimal)) / (10 ** toDecimal);

        uint256 factor;
        if (fromDecimal >= toDecimal) {
            factor = 10 ** (fromDecimal - toDecimal);
            valuation = ((amount / factor) * rate) / 1e18;
        } else {
            factor = 10 ** (toDecimal - fromDecimal);
            valuation = ((amount * factor) * rate) / 1e18;
        }

        return valuation;
    }

    /**
     * @dev Converts the given amount of tokens from one token to another using the 1inch exchange rate.
     * @param fromToken The address of the token to convert from.
     * @param toToken The address of the token to convert to.
     * @param amount The amount of tokens to convert.
     * @return valuation The converted amount of tokens.
     */
    function convertScaled(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view override returns (uint256 valuation) {
        uint256 rate;

        uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
        uint8 toDecimal = IERC20Metadata(toToken).decimals();

        rate = rates[address(fromToken)][address(toToken)];

        rate = (rate * (10 ** fromDecimal)) / (10 ** toDecimal);

        uint256 scalingFactor;
        uint256 tokenAmount;
        uint256 finalScalingFactor = 10 ** (18 - toDecimal);

        if (fromDecimal == toDecimal) {
            valuation = (amount * rate) / 1e18;
        } else if (fromDecimal > toDecimal) {
            scalingFactor = 10 ** (fromDecimal - toDecimal);
            tokenAmount = amount / scalingFactor;
            valuation = (tokenAmount * rate) / 1e18;
        } else {
            scalingFactor = 10 ** (toDecimal - fromDecimal);
            tokenAmount = amount * scalingFactor;
            valuation = (tokenAmount * rate) / 1e18;
        }

        valuation = valuation * finalScalingFactor;

        return valuation;
    }
}
