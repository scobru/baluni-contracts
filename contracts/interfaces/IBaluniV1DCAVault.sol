// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1DCAVault {
    function baseAsset() external view returns (address);
    function quoteAsset() external view returns (address);
    function registry() external view returns (address);
    function lastDeposit() external view returns (uint256);
    function deposit(uint256 amount, address to) external;
    function withdraw(uint256 shares, address to) external;
    function pause() external;
    function unpause() external;
    function totalValuation() external view returns (uint256);
    function unitPrice() external view returns (uint256);
}
