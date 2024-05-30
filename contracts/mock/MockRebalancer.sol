// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '../interfaces/IBaluniV1Rebalancer.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

contract MockRebalancer {
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
    uint256 public constant USDT_TO_USDC_RATE = 998588636583774074;
    uint256 public constant USDT_TO_WETH_RATE = 256884484348670192973112135;
    uint256 public constant USDT_TO_WMATIC_RATE = 1351542478738482785523886658083;

    uint256 public constant WETH_TO_WMATIC_RATE = 5273576410685072782753;
    uint256 public constant WETH_TO_USDC_RATE = 3836478742;
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

    function setRate(address fromToken, address toToken, uint256 rate) external {
        rates[fromToken][toToken] = rate;
    }

    function getRate(IERC20 fromToken, IERC20 toToken, bool /*isBuying*/) external view returns (uint256) {
        return rates[address(fromToken)][address(toToken)];
    }

    function getRateToEth(IERC20 fromToken, bool /*isBuying*/) external view returns (uint256) {
        return rates[address(fromToken)][WNATIVE];
    }

    function rebalance(
        address[] calldata /* assets */,
        uint256[] calldata /* weights */,
        address /* caller */,
        address /* receiver */,
        uint256 /* trigger */
    ) external {}

    function checkRebalance(
        address[] calldata /* assets */,
        uint256[] calldata /* weights */,
        uint256[] calldata /* amounts */
    ) external view returns (bool) {
        return true;
    }

    function getBaluniRouter() external view returns (address) {
        return address(0);
    }

    function getTreasury() external view returns (address) {
        return treasury;
    }

    function setTreasury(address _treasury) external {
        treasury = _treasury;
    }

    function convert(address fromToken, address toToken, uint256 amount) external view returns (uint256) {
        uint256 rate;

        uint8 fromDecimal = IERC20Metadata(fromToken).decimals();
        uint8 toDecimal = IERC20Metadata(toToken).decimals();

        uint256 numerator = 10 ** fromDecimal;
        uint256 denominator = 10 ** toDecimal;

        rate = rates[address(fromToken)][address(toToken)];
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
