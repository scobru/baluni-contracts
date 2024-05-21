// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

interface IBaluniV1Pool {
  function performRebalanceIfNeeded() external;
}
