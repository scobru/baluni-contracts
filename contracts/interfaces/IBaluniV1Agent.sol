pragma solidity 0.8.25;

interface IBaluniV1Agent {
  struct Call {
    address to;
    uint256 value;
    bytes data;
  }

  function execute(Call[] memory calls, address[] memory tokensReturn) external;
}
