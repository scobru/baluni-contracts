// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RebalancerMock {
  address private usdc;
  address private eth;
  address private wbtc;

  constructor(address _usdc,address _wbtc, address _eth ) {
    usdc = _usdc;
    eth = _eth;
    wbtc = _wbtc;
  }

  function getWNATIVEAddress() external view returns (address) {
    return eth;
  }

  function getUSDCAddress() external view returns (address) {
    return usdc;
  }

  function getRateToEth(address token, bool) external view returns (uint256) {
    if (token == usdc) {
      return 3748153863; // Example rate for USDC to ETH
    } else {
      return 184238574531613859797407070933; // Example rate for other tokens to ETH
    }
  }

  function getRate(address fromToken, address toToken, bool) external view returns (uint256) {
    if (fromToken == usdc && toToken == eth) {
      return 3748153863; // USDC to ETH
    } else if (fromToken == wbtc && toToken == eth) {
      return 184238574531613859797407070933; // WBTC to ETH
    } else if (fromToken == wbtc && toToken == usdc) {
      return 689489375682604008475; // WBTC to USDC
    } else if (fromToken == eth && toToken == usdc) {
      return 3748153863; // ETH to USDC
    } else {
      return 1; // Default rate for other pairs
    }
  }
}
