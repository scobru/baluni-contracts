// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface I1inchSpotAgg {
  function getRate(IERC20 srcToken, IERC20 dstToken, bool useWrappers) external view returns (uint256 weightedRate);

  function getRateToEth(IERC20 srcToken, bool useWrappers) external view returns (uint256 weightedRate);
}
