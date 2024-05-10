// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BaluniStake is ReentrancyGuard {
	using SafeMath for uint256;

	IERC20 public immutable stakingToken;
	IERC20 public immutable rewardToken;

	mapping(address => uint256) public balanceStakedOf;
	mapping(address => uint256) public stakeTimestamp;
	uint256 public stakingSupply;

	uint256 private constant MULTIPLIER = 1e18;
	uint256 private rewardIndex;
	mapping(address => uint256) private rewardIndexOf;
	mapping(address => uint256) private earned;

	uint256 private constant STAKING_PERIOD = 365 days;

	event RewardClaimed(address indexed user, uint256 amount);
	event Staked(address indexed user, uint256 amount);
	event Unstaked(address indexed user, uint256 amount);

	constructor(address _stakingToken, address _rewardToken) {
		require(
			_stakingToken != address(0) && _rewardToken != address(0),
			"Invalid token address"
		);
		stakingToken = IERC20(_stakingToken);
		rewardToken = IERC20(_rewardToken);
	}

	function updateRewardIndex(uint256 reward) internal {
		if (stakingSupply > 0) {
			rewardIndex = rewardIndex.add(
				reward.mul(MULTIPLIER).div(stakingSupply)
			);
		}
	}

	function updateRewardIndexPublic(uint256 reward) public {
		require(reward > 0, "Reward must be positive");
		require(stakingSupply > 0, "No staking supply to distribute rewards");
		rewardToken.transferFrom(msg.sender, address(this), reward);
		updateRewardIndex(reward);
	}

	function _calculateRewards(address account) private view returns (uint256) {
		uint256 timeStaked = block.timestamp.sub(stakeTimestamp[account]);
		timeStaked = timeStaked > STAKING_PERIOD ? STAKING_PERIOD : timeStaked;
		uint256 shares = balanceStakedOf[account];
		uint256 rewardDelta = rewardIndex.sub(rewardIndexOf[account]);
		return
			shares.mul(timeStaked).mul(rewardDelta).div(MULTIPLIER).div(
				STAKING_PERIOD
			);
	}

	function calculateRewardsEarned(
		address account
	) external view returns (uint256) {
		return earned[account].add(_calculateRewards(account));
	}

	function _updateRewards(address account) internal {
		uint256 rewards = _calculateRewards(account);
		earned[account] = earned[account].add(rewards);
		rewardIndexOf[account] = rewardIndex;
	}

	function stake(uint256 amount) external nonReentrant {
		_updateRewards(msg.sender);
		balanceStakedOf[msg.sender] = balanceStakedOf[msg.sender].add(amount);
		stakingSupply = stakingSupply.add(amount);
		stakeTimestamp[msg.sender] = block.timestamp;
		stakingToken.transferFrom(msg.sender, address(this), amount);
		emit Staked(msg.sender, amount);
	}

	function unstake(uint256 amount) external nonReentrant {
		_updateRewards(msg.sender);
		uint256 currentBalance = balanceStakedOf[msg.sender];
		require(currentBalance >= amount, "Insufficient balance to unstake");
		balanceStakedOf[msg.sender] = currentBalance.sub(amount);
		stakingSupply = stakingSupply.sub(amount);
		stakingToken.transfer(msg.sender, amount);
		emit Unstaked(msg.sender, amount);
	}

	function claim() external nonReentrant returns (uint256) {
		_updateRewards(msg.sender);
		uint256 reward = earned[msg.sender];
		require(reward > 0, "No rewards to claim");
		earned[msg.sender] = 0;
		rewardToken.transfer(msg.sender, reward);
		emit RewardClaimed(msg.sender, reward);
		return reward;
	}

	function claimTo(
		address staker,
		address _to
	) public nonReentrant returns (uint256) {
		_updateRewards(staker);
		uint256 reward = earned[staker];
		require(reward > 0, "No rewards to claim");
		earned[staker] = 0;
		rewardToken.transfer(_to, reward);
		emit RewardClaimed(_to, reward);
		return reward;
	}
}
