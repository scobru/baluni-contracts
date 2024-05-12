pragma solidity 0.8.25;

interface IBaluniV1RewardPool {
  function notifyRewardAmount(address _reward, uint256 _amount, uint256 _duration) external;
}
