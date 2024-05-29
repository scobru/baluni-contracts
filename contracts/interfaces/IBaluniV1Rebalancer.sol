// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import './IBaluniV1Router.sol';

interface IBaluniV1Rebalancer {
  struct RebalanceVars {
    uint256 length;
    uint256 totalValue;
    uint256 finalUsdBalance;
    uint256 overweightVaultsLength;
    uint256 underweightVaultsLength;
    uint256 totalActiveWeight;
    uint256 amountOut;
    uint256[] overweightVaults;
    uint256[] overweightAmounts;
    uint256[] underweightVaults;
    uint256[] underweightAmounts;
    uint256[] balances;
  }

  // Variables
  function baluniRouter() external view returns (IBaluniV1Router);

  function USDC() external view returns (IERC20);

  function WNATIVE() external view returns (IERC20Metadata);

  function uniswapRouter() external view returns (ISwapRouter);

  function uniswapFactory() external view returns (IUniswapV3Factory);

  function _1InchSpotAgg() external view returns (I1inchSpotAgg);

  function treasury() external view returns (address);

  function usdc() external view returns (address);

  function wnative() external view returns (address);

  // Functions
  function rebalance(
    uint256[] memory balances,
    address[] calldata assets,
    uint256[] calldata weights,
    uint256 limit,
    address sender,
    address receiver,
    address baseAsset
  ) external;

  function checkRebalance(
    uint256[] memory balances,
    address[] calldata assets,
    uint256[] calldata weights,
    uint256 limit,
    address sender,
    address baseAsset
  ) external view returns (RebalanceVars memory);

  function singleSwap(
    address token0,
    address token1,
    uint256 amount,
    address receiver
  ) external returns (uint256 amountOut);

  function multiHopSwap(
    address token0,
    address token1,
    address token2,
    uint256 amount,
    address receiver
  ) external returns (uint256 amountOut);

  function convert(address fromToken, address toToken, uint256 amount) external view returns (uint256);
}
