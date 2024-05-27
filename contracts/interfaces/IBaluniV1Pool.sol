// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

interface IBaluniV1Pool {
  // Views
  function rebalancer() external view returns (address);

  function assets(uint256 index) external view returns (address);

  function weights(uint256 index) external view returns (uint256);

  function trigger() external view returns (uint256);

  function ONE() external view returns (uint256);

  function router() external view returns (address);

  function SWAP_FEE_BPS() external view returns (uint256);

  function getReserves() external view returns (uint256[] memory);

  function getAssets() external view returns (address[] memory);

  function getWeights() external view returns (uint256[] memory);

  function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256);

  function performRebalanceIfNeeded(address _sender) external;

  function getDeviation() external view returns (bool[] memory directions, uint256[] memory deviations);

  function assetLiquidity(uint256 assetIndex) external view returns (uint256);

  function liquidity() external view returns (uint256);

  function unitPrice() external view returns (uint256);

  // Mutative
  function rebalanceWeights(address receiver) external;

  function swap(address fromToken, address toToken, uint256 amount, address receiver) external returns (uint256);

  function mint(address to) external returns (uint256);

  function burn(address to) external;

  function changeRebalancer(address _newRebalancer) external;

  function changeRouter(address _newRouter) external;

  // Events
  event RebalancePerformed(address indexed by, address[] assets);
  event WeightsRebalanced(address indexed user, uint256[] amountsAdded);
  event Burn(address indexed user, uint256 sharesBurned);
  event Mint(address indexed to, uint256 sharesMinted);
  event Swap(
    address indexed user,
    address indexed fromToken,
    address indexed toToken,
    uint256 amountIn,
    uint256 amountOut
  );
}
