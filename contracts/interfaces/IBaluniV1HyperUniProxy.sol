// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;
interface IBaluniV1HyperUniProxy {
    function deposit(
        uint256 deposit0,
        uint256 deposit1,
        address to,
        address from,
        address pos
    ) external returns (uint256 shares);

    function getDepositAmount(
        address pos,
        address token,
        uint256 _deposit
    ) external view returns (uint256 amountStart, uint256 amountEnd);
}
