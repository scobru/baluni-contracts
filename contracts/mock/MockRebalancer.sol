// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '../interfaces/IBaluniV1Rebalancer.sol';

contract MockRebalancer {
  mapping(address => mapping(address => uint256)) public rates;

  // Hardcoded rates
  uint256 public constant USDC_TO_WETH_RATE = 1376418375228432834760617723251;
  uint256 public constant USDT_TO_WETH_RATE = 1375238770025523092477539783146;
  uint256 public constant USDC_TO_USDT_RATE = 1000983989838925640;
  uint256 public constant USDT_TO_USDC_RATE = 998714700668848356;
  uint256 public constant WMATIC_TO_USDT_RATE = 747767;
  uint256 public constant WMATIC_TO_USDC_RATE = 746814;
  uint256 public constant WETH_TO_WMATIC_RATE = 5292121379569319089949;
  uint256 public constant WBTC_TO_WMATIC_RATE = 930502153725374937460554691581275;
  uint256 public constant WBTC_TO_USDT_RATE = 681360233243484009138;
  uint256 public constant USDT_TO_WBTC_RATE = 1466684783076298;
  uint256 public constant WBTC_TO_USDC_RATE = 681360233243484009138;
  uint256 public constant USDC_TO_WBTC_RATE = 1469017312082312;
  address public wmatic;
  address public treasury;

  constructor(address usdc, address usdt, address _wmatic, address weth, address wbtc) {
    rates[usdc][_wmatic] = USDC_TO_WETH_RATE;
    rates[usdt][_wmatic] = USDT_TO_WETH_RATE;
    rates[_wmatic][usdc] = WMATIC_TO_USDT_RATE;
    rates[_wmatic][usdt] = WMATIC_TO_USDC_RATE;
    rates[usdc][usdt] = USDC_TO_USDT_RATE;
    rates[usdt][usdc] = USDT_TO_USDC_RATE;
    rates[usdc][wbtc] = USDC_TO_WBTC_RATE;
    rates[wbtc][usdc] = WBTC_TO_USDC_RATE;
    rates[usdt][wbtc] = USDT_TO_WBTC_RATE;
    rates[wbtc][usdt] = WBTC_TO_USDT_RATE;
    rates[wbtc][_wmatic] = WBTC_TO_WMATIC_RATE;
    rates[_wmatic][wbtc] = WETH_TO_WMATIC_RATE;
    rates[weth][_wmatic] = WETH_TO_WMATIC_RATE;

    wmatic = _wmatic;
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
}
