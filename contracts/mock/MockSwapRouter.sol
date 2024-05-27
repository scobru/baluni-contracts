// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract MockSwapRouter {
  struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
  }

  struct ExactInputParams {
    address[] path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
  }

  function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut) {
    // Mock implementation returning amountIn as amountOut for simplicity
    return params.amountIn;
  }

  function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut) {
    // Mock implementation returning amountIn as amountOut for simplicity
    return params.amountIn;
  }
}
