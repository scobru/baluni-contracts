// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';

interface IBaluniV1Pool {
  function getAssets() external view returns (address[] memory);

  function getWeights() external view returns (uint256[] memory);

  function swap(address fromToken, address toToken, uint256 amount) external returns (uint256);

  function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256);

  function addLiquidity(uint256[] calldata amounts) external returns (uint256);

  function addLiquiditySingleAsset(IERC20 asset, uint256 amount) external returns (uint256);

  function exit(uint256 share) external;

  function performRebalanceIfNeeded(address _sender) external;

  function getDeviation() external view returns (bool[] memory directions, uint256[] memory deviations);

  function assetToStable(uint256 assetIndex) external view returns (uint256);

  function totalLiquidityStable() external view returns (uint256);

  function getUnitPriceStable() external view returns (uint256);

  function getReserves() external view returns (uint256[] memory);

  function isAssetSupported(address asset) external view returns (bool);

  function totalLiquidityInToken(address token) external view returns (uint256);

  function assets(uint256 index) external view returns (address);

  function balances(address token) external view returns (uint256);

  function weights(uint256 index) external view returns (uint256);
}
