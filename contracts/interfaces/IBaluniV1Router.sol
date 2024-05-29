// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import './I1inchSpotAgg.sol';
import './IBaluniV1Agent.sol';

interface IBaluniV1Router {
  struct Call {
    address to;
    uint256 value;
    bytes data;
  }

  // Variables
  function _MAX_BPS_FEE() external view returns (uint256);

  function _BPS_FEE() external view returns (uint256);

  function _BPS_BASE() external view returns (uint256);

  function getTokens() external view returns (address[] memory);

  function USDC() external view returns (IERC20);

  function WNATIVE() external view returns (address);

  function oracle() external view returns (address);

  function uniswapRouter() external view returns (address);

  function uniswapFactory() external view returns (address);

  function agentFactory() external view returns (address);

  function marketOracle() external view returns (address);

  function rebalancer() external view returns (address);

  function treasury() external view returns (address);

  // Functions
  function initialize(
    address _usdc,
    address _wnative,
    address _1inchSpotAgg,
    address _uniRouter,
    address _uniFactory,
    address _rebalancer
  ) external;

  function reinitialize(
    address _usdc,
    address _wnative,
    address _1inchSpotAgg,
    address _uniRouter,
    address _uniFactory,
    address _rebalancer,
    uint64 version
  ) external;

  function initializeMarketOracle(address _marketOracle) external;

  function changeMarketOracle(address _marketOracle) external;

  function changeBpsFee(uint256 _newFee) external;

  function changeTreasury(address _newTreasury) external;

  function changeRebalancer(address _newRebalancer) external;

  function changeAgentFactory(address _agentFactory) external;

  function execute(IBaluniV1Agent.Call[] memory calls, address[] memory tokensReturn) external;

  function liquidate(address token) external;

  function liquidateAll() external;

  function burnERC20(uint256 burnAmount) external;

  function burnUSDC(uint256 burnAmount) external;

  function getAgentAddress(address _user) external view returns (address);

  function mintWithUSDC(uint256 balAmountToMint) external;

  function callRebalance(
    address[] calldata assets,
    uint256[] calldata weights,
    address sender,
    address receiver,
    uint256 limit,
    address baseAsset
  ) external;

  function requiredUSDCtoMint(uint256 balAmountToMint) external view returns (uint256);

  function calculateTokenShare(
    uint256 totalBaluni,
    uint256 totalERC20Balance,
    uint256 baluniAmount,
    uint256 tokenDecimals
  ) external pure returns (uint256);

  function tokenValuation(uint256 amount, address token) external view returns (uint256);

  function totalValuation() external view returns (uint256);

  function getUSDCShareValue(uint256 amount) external view returns (uint256);

  function fetchMarketPrices() external view returns (uint256, uint256);

  function getVersion() external view returns (uint64);

  function unitPrice() external view returns (uint256);
  
}
