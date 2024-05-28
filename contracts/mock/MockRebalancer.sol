// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '../interfaces/IBaluniV1Rebalancer.sol';

contract MockRebalancer {
  mapping(address => mapping(address => uint256)) public rates;

  // Hardcoded rates
  uint256 public constant USDC_TO_WETH_RATE = 256897185735855109411507118;
  uint256 public constant USDC_TO_USDT_RATE = 1000983989838925640;
  uint256 public constant USDC_TO_WBTC_RATE = 1463657468947761;
  uint256 public constant USDC_TO_WMATIC_RATE = 1351148249095651365340914098616;

  uint256 public constant WMATIC_TO_USDT_RATE = 747767;
  uint256 public constant WMATIC_TO_USDC_RATE = 739533;
  uint256 public constant WMATIC_TO_WBTC_RATE = 1080;
  uint256 public constant WMATIC_TO_WETH_RATE = 189625582664100;

  uint256 public constant WBTC_TO_WMATIC_RATE = 924778033538811846038762973579739;
  uint256 public constant WBTC_TO_USDT_RATE = 681360233243484009138;
  uint256 public constant WBTC_TO_WETH_RATE = 175476470939493533556108593598;
  uint256 public constant WBTC_TO_USDC_RATE = 681360233243484009138;

  uint256 public constant USDT_TO_WBTC_RATE = 1457844841452943;
  uint256 public constant USDT_TO_USDC_RATE = 998714700668848356;
  uint256 public constant USDT_TO_WETH_RATE = 256884484348670192973112135;
  uint256 public constant USDT_TO_WMATIC_RATE = 1351542478738482785523886658083;

  uint256 public constant WETH_TO_WMATIC_RATE = 5273576410685072782753;

  address public wmatic;
  address public treasury;

  constructor(address usdc, address usdt, address _wmatic, address weth, address wbtc) {
    wmatic = _wmatic;

    rates[usdt][usdc] = USDT_TO_USDC_RATE;
    rates[usdt][wbtc] = USDT_TO_WBTC_RATE;
    rates[usdt][weth] = USDT_TO_WETH_RATE;
    rates[usdt][wmatic] = USDT_TO_WMATIC_RATE;

    rates[wbtc][usdt] = WBTC_TO_USDT_RATE;
    rates[wbtc][wmatic] = WBTC_TO_WMATIC_RATE;
    rates[wbtc][usdc] = WBTC_TO_USDC_RATE;
    rates[wbtc][weth] = WBTC_TO_WETH_RATE;

    rates[usdc][usdt] = USDC_TO_USDT_RATE;
    rates[usdc][wbtc] = USDC_TO_WBTC_RATE;
    rates[usdc][wmatic] = USDC_TO_WMATIC_RATE;
    rates[usdc][weth] = USDC_TO_WETH_RATE;

    rates[wmatic][wbtc] = WMATIC_TO_WBTC_RATE;
    rates[wmatic][weth] = WMATIC_TO_WETH_RATE;
    rates[wmatic][usdc] = WMATIC_TO_USDC_RATE;
    rates[wmatic][usdt] = WMATIC_TO_USDT_RATE;

    rates[weth][wmatic] = WETH_TO_WMATIC_RATE;
  }

  function setRate(address fromToken, address toToken, uint256 rate) external {
    rates[fromToken][toToken] = rate;
  }

  function getRate(IERC20 fromToken, IERC20 toToken, bool /*isBuying*/) external view returns (uint256) {
    return rates[address(fromToken)][address(toToken)];
  }

  function getRateToEth(IERC20 fromToken, bool /*isBuying*/) external view returns (uint256) {
    return rates[address(fromToken)][wmatic];
  }

  function getWNATIVEAddress() external view returns (address) {
    return wmatic;
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

  function getUSDCAddress() external view returns (address) {
    return address(0);
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
