// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1MarketOracle {
  function _unitPriceBALUNI() external view returns (uint256);

  function _priceBALUNI() external view returns (uint256);
}
