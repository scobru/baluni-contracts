// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1Router {
  function getAgentAddress(address _user) external view returns (address);

  function getBpsFee() external view returns (uint256);

  function tokenValuation(
    uint256 amount,
    address token
  ) external view returns (uint256);

  function getTreasury() external view returns (address);
}
