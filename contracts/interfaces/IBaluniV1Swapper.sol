// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1Swapper {
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
}
