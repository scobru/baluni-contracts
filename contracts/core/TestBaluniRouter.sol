// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "hardhat/console.sol";

contract TestBaluniRouter {
	// Constructor to initialize the parent contract's data

	function calculateTokenShare(
		uint256 totalBaluni,
		uint256 totalERC20Balance,
		uint256 amountBaluni,
		uint256 tokenDecimals
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
		console.log("result: %s", result);
		// Scale down the result to have tokenDecimals
		return result;
	}
}
