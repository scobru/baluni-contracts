// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1Oracle {
    function convert(address fromToken, address toToken, uint256 amount) external view returns (uint256 valuation);

    function convertScaled(
        address fromToken,
        address toToken,
        uint256 amount
    ) external view returns (uint256 valuation);
}
