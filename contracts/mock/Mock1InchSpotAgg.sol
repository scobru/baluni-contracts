// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import '../interfaces/I1inchSpotAgg.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Mock1inchSpotAgg is I1inchSpotAgg {
  uint256 public rate;
  uint256 public rateToEth;

  uint256 public constant USDC_TO_WETH_RATE = 1376418375228432834760617723251;
  uint256 public constant USDT_TO_WETH_RATE = 1375238770025523092477539783146;
  uint256 public constant USDC_TO_USDT_RATE = 1000983989838925640;
  uint256 public constant USDT_TO_USDC_RATE = 998714700668848356;
  uint256 public constant WMATIC_TO_USDT_RATE = 747767;
  uint256 public constant WMATIC_TO_USDC_RATE = 746814;

  address public wmatic;
  address public treasury;

  mapping(address => mapping(address => uint256)) public rates;

  constructor(address usdc, address usdt, address _wmatic) {
    rates[usdc][_wmatic] = USDC_TO_WETH_RATE;
    rates[usdt][_wmatic] = USDT_TO_WETH_RATE;
    rates[_wmatic][usdc] = WMATIC_TO_USDT_RATE;
    rates[_wmatic][usdt] = WMATIC_TO_USDC_RATE;
    rates[usdc][usdt] = USDC_TO_USDT_RATE;
    rates[usdt][usdc] = USDT_TO_USDC_RATE;
    wmatic = _wmatic;
  }

  function getRate(IERC20 fromToken, IERC20 toToken, bool /*isBuying*/) external view returns (uint256) {
    return rates[address(fromToken)][address(toToken)];
  }

  function getRateToEth(IERC20 fromToken, bool /*isBuying*/) external view returns (uint256) {
    return rates[address(fromToken)][wmatic];
  }

  function getTreasury() external view returns (address) {
    return treasury;
  }

  function setTreasury(address _treasury) external {
    treasury = _treasury;
  }
}
