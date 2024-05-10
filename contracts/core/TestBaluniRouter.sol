// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract TestBaluniRouter {
	// Constructor to initialize the parent contract's data

	function calculateTokenShare(
		uint256 totalBaluni,
		uint256 totalERC20Balance,
		uint256 amountBaluni,
		uint8 tokenDecimals
	) public pure returns (uint256) {
		uint256 baluniAdjusted;
		uint256 amountAdjusted;

		if (tokenDecimals < 18) {
			baluniAdjusted = totalBaluni / (10 ** (18 - tokenDecimals));
			amountAdjusted = amountBaluni / (10 ** (18 - tokenDecimals));
		} else {
			baluniAdjusted = totalBaluni;
			amountAdjusted = amountBaluni;
		}

		uint256 result = (amountAdjusted * totalERC20Balance) / baluniAdjusted;
		// Scale down the result to have tokenDecimals
		return result;
	}

	function calculateTokenShare2(
		uint256 totalBaluni,
		uint256 totalERC20Balance,
		uint256 amountBaluni,
		uint8 tokenDecimals
	) public pure returns (uint256) {
		uint256 baluniAdjusted;
		uint256 amountAdjusted;
		uint256 result;
		if (tokenDecimals < 18) {
			totalERC20Balance =
				totalERC20Balance *
				(10 ** (18 - tokenDecimals));
			result = (amountBaluni * totalERC20Balance) / totalBaluni;
			return result / (10 ** (18 - tokenDecimals));
		} else {
			baluniAdjusted = totalBaluni;
			amountAdjusted = amountBaluni;
			result = (amountAdjusted * totalERC20Balance) / baluniAdjusted;
		}

		// Scale down the result to have tokenDecimals
		return result;
	}
}
