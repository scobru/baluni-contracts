// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract BaluniStake {
	IERC20 public immutable stakingToken;
	IERC20 public immutable rewardToken;

	mapping(address => uint256) public balanceStakedOf;
	mapping(address => uint256) public stakeTimestamp;
	uint256 public stakingSupply;

	uint256 private constant MULTIPLIER = 1e18;
	uint256 private rewardIndex;
	mapping(address => uint256) private rewardIndexOf;
	mapping(address => uint256) private earned;

	constructor(address _stakingToken, address _rewardToken) {
		stakingToken = IERC20(_stakingToken);
		rewardToken = IERC20(_rewardToken);
	}

	uint256 private constant STAKING_PERIOD = 365 days;

	event RewardClaimed(address indexed user, uint256 amount);

	/**
	 * @dev Updates the reward index based on the given reward amount.
	 * @param reward The amount of reward to be added.
	 */
	function updateRewardIndex(uint256 reward) internal {
		rewardIndex += (reward * MULTIPLIER) / stakingSupply;
	}

	/**
	 * @dev Updates the reward index by adding the specified reward to the current reward index.
	 * This function is public and can be called by any address.
	 * @param reward The amount of reward tokens to be added to the reward index.
	 */
	function updateRewardIndexPublic(uint256 reward) public {
		rewardToken.transferFrom(msg.sender, address(this), reward);
		rewardIndex += (reward * MULTIPLIER) / stakingSupply;
	}

	/**
	 * @dev Calculates the rewards for the specified account.
	 * @param account The address of the account to calculate rewards for.
	 * @return The calculated rewards for the account.
	 */
	function _calculateRewards(address account) private view returns (uint256) {
		uint256 shares = balanceStakedOf[account];
		uint256 timeStaked = block.timestamp - stakeTimestamp[account];
		if (timeStaked > STAKING_PERIOD) {
			timeStaked = STAKING_PERIOD;
		}
		return
			(shares * timeStaked * (rewardIndex - rewardIndexOf[account])) /
			MULTIPLIER /
			STAKING_PERIOD;
	}

	/**
	 * @dev Calculates the total rewards earned by an account.
	 * @param account The address of the account.
	 * @return The total rewards earned by the account.
	 */
	function calculateRewardsEarned(
		address account
	) external view returns (uint256) {
		return earned[account] + _calculateRewards(account);
	}

	/**
	 * @dev Updates the rewards for an account.
	 * @param account The address of the account.
	 */
	function _updateRewards(address account) internal {
		earned[account] += _calculateRewards(account);
		rewardIndexOf[account] = rewardIndex;
	}

	/**
	 * @dev Stakes a specified amount of tokens.
	 * @param amount The amount of tokens to stake.
	 */
	function stake(uint256 amount) external {
		_updateRewards(msg.sender);
		stakeTimestamp[msg.sender] = block.timestamp;
		balanceStakedOf[msg.sender] += amount;
		stakingSupply += amount;

		stakingToken.transferFrom(msg.sender, address(this), amount);
	}

	/**
	 * @dev Allows a user to unstake a specified amount of tokens.
	 * @param amount The amount of tokens to unstake.
	 */
	function unstake(uint256 amount) external {
		_updateRewards(msg.sender);

		balanceStakedOf[msg.sender] -= amount;
		stakingSupply -= amount;

		stakingToken.transfer(msg.sender, amount);
	}

	/**
	 * @dev Allows a user to claim their earned rewards.
	 * @return The amount of rewards claimed.
	 */
	function claim() external returns (uint256) {
		_updateRewards(msg.sender);

		uint256 reward = earned[msg.sender];
		if (reward > 0) {
			earned[msg.sender] = 0;
			//rewardToken.approve(msg.sender, reward);
			rewardToken.transfer(msg.sender, reward);
		}

		emit RewardClaimed(msg.sender, reward);

		return reward;
	}

	/**
	 * @dev Allows a user to claim their earned rewards and transfer them to a specified address.
	 * @param _to The address to transfer the rewards to.
	 * @return The amount of rewards claimed.
	 */
	function claimTo(address staker, address _to) public returns (uint256) {
		_updateRewards(staker);

		uint256 reward = earned[staker];
		if (reward > 0) {
			earned[staker] = 0;
			rewardToken.approve(_to, reward);
			rewardToken.transfer(_to, reward);
		}

		return reward;
	}
}
