// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1Pool {
  function rebalancer() external view returns (address);

  function asset1() external view returns (address);

  function asset2() external view returns (address);

  function weight1() external view returns (uint256);

  function weight2() external view returns (uint256);

  function oracle() external view returns (address);

  function SWAP_FEE_BPS() external view returns (uint256);

  function swap(address fromToken, address toToken, uint256 amount) external returns (uint256);

  function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256);

  function addLiquidity(uint256 amount1, uint256 amount2) external returns (uint256);

  function exit(uint256 share) external;

  function totalLiquidityAsset1() external view returns (uint256);

  function totalLiquidityAsset2() external view returns (uint256);

  function totalLiquidityStable() external view returns (uint256);

  function valuationAsset1() external view returns (uint256);

  function valuationAsset2() external view returns (uint256);

  function performRebalanceIfNeeded(address _sender) external;

  function getDeviation() external view returns (bool, uint256, bool, uint256);

  function getReserves() external view returns (uint256, uint256);

  function transfer(address to, uint256 share) external;

  function transferFrom(address from, address to, uint256 share) external;

  function approve(address spender, uint256 share) external;

  event Swap(
    address indexed user,
    address indexed fromToken,
    address indexed toToken,
    uint256 amountIn,
    uint256 amountOut
  );
  event LiquidityAdded(address indexed user, uint256 amount1, uint256 amount2, uint256 sharesMinted);
  event LiquidityRemoved(address indexed user, uint256 asset1Amount, uint256 asset2Amount, uint256 sharesBurned);
  event RebalancePerformed(address indexed by, address[] assets);
}
