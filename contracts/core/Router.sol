// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 *  __                  __                      __
 * /  |                /  |                    /  |
 * $$ |____    ______  $$ | __    __  _______  $$/
 * $$      \  /      \ $$ |/  |  /  |/       \ /  |
 * $$$$$$$  | $$$$$$  |$$ |$$ |  $$ |$$$$$$$  |$$ |
 * $$ |  $$ | /    $$ |$$ |$$ |  $$ |$$ |  $$ |$$ |
 * $$ |__$$ |/$$$$$$$ |$$ |$$ \__$$ |$$ |  $$ |$$ |
 * $$    $$/ $$    $$ |$$ |$$    $$/ $$ |  $$ |$$ |
 * $$$$$$$/   $$$$$$$/ $$/  $$$$$$/  $$/   $$/ $$/
 *
 *
 *                  ,-""""-.
 *                ,'      _ `.
 *               /       )_)  \
 *              :              :
 *              \              /
 *               \            /
 *                `.        ,'
 *                  `.    ,'
 *                    `.,'
 *                     /\`.   ,-._
 *                         `-'    \__
 *                              .
 *               s                \
 *                                \\
 *                                 \\
 *                                  >\/7
 *                              _.-(6'  \
 *                             (=___._/` \
 *                                  )  \ |
 *                                 /   / |
 *                                /    > /
 *                               j    < _\
 *                           _.-' :      ``.
 *                           \ r=._\        `.
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./Agent.sol";

contract Router is Ownable, ERC20 {
	using SafeERC20 for IERC20;

	uint256 public _BPS_FEE = 10;
	uint256 public _MINT_RATE = 2;
	uint256 public _REWARD_RATE = 100;

	uint256 internal constant _MAX_FEE = 100;
	uint256 internal constant _MIN_MINT_RATE = 2;
	uint256 internal constant _MAX_REWARD_RATE = 10000;
	uint256 internal constant _MIN_REWARD_RATE = 10;

	IERC20 internal constant USDC =
		IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);

	mapping(address => Agent) public userAgents;
	mapping(address => uint256) public stakes;
	mapping(address => uint256) public stakingTime;

	uint256 public totalStaked;

	event Staked(address indexed user, uint256 amount, uint256 timestamp);
	event Unstaked(address indexed user, uint256 amount, uint256 reward);
	event AgentCreated(address user, address agent);
	event Execute(address user, Agent.Call[] calls, address[] tokensReturn);
	event Burn(address user, uint256 value);
	event Mint(address user, uint256 value);
	event TransferAfterMint(address user, uint256 value);
	event ChangeMintRate(uint256 newRate);
	event ChangeRewardRate(uint256 newRate);
	event ChangeBpsFee(uint256 newFee);

	constructor() Ownable(msg.sender) ERC20("Baluni", "BALUNI") {}

	function getBpsFee() external view returns (uint256) {
		return _BPS_FEE;
	}

	function getMintRate() external view returns (uint256) {
		return _MINT_RATE;
	}

	function changeBpsFee(uint256 _newFee) external returns (bool) {
		require(msg.sender == owner(), "Only Owner");
		require(_newFee <= _MAX_FEE, "Fee too high");
		_BPS_FEE = _newFee;
		emit ChangeBpsFee(_BPS_FEE);
		return true;
	}

	function changeRewardRate(uint256 _newRate) external returns (bool) {
		require(msg.sender == owner(), "Only Owner");
		require(
			_newRate <= _MAX_REWARD_RATE && _MIN_REWARD_RATE <= _newRate,
			"Wront Rate"
		);
		_REWARD_RATE = _newRate;
		emit ChangeRewardRate(_REWARD_RATE);
		return true;
	}

	function changeMintRate(uint256 _newMintRate) external returns (bool) {
		require(msg.sender == owner(), "Only Owner");
		require(_MIN_MINT_RATE < _newMintRate, "Fee too high");
		_MINT_RATE = _newMintRate;
		emit ChangeMintRate(_MINT_RATE);
		return true;
	}

	function getAgentAddress(address _user) public view returns (address) {
		bytes32 salt = keccak256(abi.encodePacked(_user));
		bytes memory bytecode = getBytecode(_user);

		bytes32 hash = keccak256(
			abi.encodePacked(
				bytes1(0xff),
				address(this),
				salt,
				keccak256(bytecode)
			)
		);

		return address(uint160(uint(hash)));
	}

	function getOrCreateAgent(address user) private returns (Agent) {
		bytes32 salt = keccak256(abi.encodePacked(user));

		if (address(userAgents[user]) == address(0)) {
			Agent agent = new Agent{ salt: salt }(user, address(this));
			userAgents[user] = agent;
			emit AgentCreated(user, address(agent));
		}
		return userAgents[user];
	}

	function getBytecode(address _owner) public view returns (bytes memory) {
		bytes memory bytecode = type(Agent).creationCode;
		return abi.encodePacked(bytecode, abi.encode(_owner, address(this)));
	}

	function execute(
		Agent.Call[] calldata calls,
		address[] calldata tokensReturn
	) external {
		uint256 usdBalanceB4 = USDC.balanceOf(address(this));

		Agent agent = getOrCreateAgent(msg.sender);
		agent.execute(calls, tokensReturn);

		uint256 usdBalance = USDC.balanceOf(address(this));
		uint256 mintAmount = (usdBalance - usdBalanceB4) * 1e12;

		_mint(address(this), mintAmount);
		emit Mint(address(this), mintAmount);
		uint256 mintAmountFinal = mintAmount / _MINT_RATE;

		if (
			mintAmountFinal != 0 && balanceOf(address(this)) > mintAmountFinal
		) {
			uint256 allowance = allowance(address(this), msg.sender);

			if (mintAmountFinal > allowance) {
				approve(msg.sender, mintAmountFinal);
			}

			IERC20(address(this)).safeTransfer(msg.sender, mintAmountFinal);
			emit TransferAfterMint(msg.sender, mintAmountFinal);
		}

		emit Execute(msg.sender, calls, tokensReturn);
	}

	function burnBALUNIForUSDC(uint amount) external {
		require(balanceOf(msg.sender) >= amount, "Insufficient BAL");
		uint usdcAmount = _calculateUSDCShare(amount);

		USDC.transfer(msg.sender, usdcAmount / 1e12);
		_burn(msg.sender, amount);
	}

	function mintBALUNI(uint256 amount) external {
		require(amount > 0, "Amount must be greater than 0");
		IERC20(USDC).transferFrom(msg.sender, address(this), amount);

		uint256 mintAmount = amount * 1e12;
		_mint(address(this), mintAmount);

		emit Mint(address(this), mintAmount);

		uint256 mintAmountFinal = mintAmount / _MINT_RATE;
		IERC20(address(this)).safeTransfer(msg.sender, mintAmountFinal);

		emit TransferAfterMint(msg.sender, mintAmountFinal);
	}

	function _calculateUSDCShare(uint balAmount) internal view returns (uint) {
		uint totalSupply = totalSupply();
		uint totalUSDCBalance = USDC.balanceOf(address(this));
		uint scaledUSDCBalance = totalUSDCBalance * 1e12;

		return (balAmount * scaledUSDCBalance) / totalSupply;
	}

	function withdrawRewards() external {
		uint256 reward = _calculateReward(msg.sender, stakes[msg.sender]);
		require(
			reward <= balanceOf(address(this)) - totalStaked,
			"Insufficient rewards available"
		);
		_transfer(address(this), msg.sender, reward);
		emit RewardWithdrawn(msg.sender, reward);
	}

	function getShare(uint balAmount) external view returns (uint) {
		return _calculateUSDCShare(balAmount);
	}

	function stake(uint256 amount) external {
		require(amount > 0, "Amount must be greater than 0");
		uint256 allowed = allowance(msg.sender, address(this));
		require(allowed >= amount, "Check the token allowance");
		IERC20(address(this)).safeTransferFrom(
			msg.sender,
			address(this),
			amount
		);
		stakes[msg.sender] += amount;
		stakingTime[msg.sender] = block.timestamp;
		totalStaked += amount;
		emit Staked(msg.sender, amount, block.timestamp);
	}

	function unstake(uint256 amount) external {
		require(stakes[msg.sender] >= amount, "Insufficient staked amount");
		uint256 reward = _calculateReward(msg.sender, amount);
		uint256 totalNeeded = amount + reward;

		require(
			balanceOf(address(this)) >= totalNeeded,
			"Not enough tokens in the contract"
		);

		_transfer(address(this), msg.sender, totalNeeded);
		stakes[msg.sender] -= amount;

		if (stakes[msg.sender] == 0) {
			stakingTime[msg.sender] = 0;
		}

		totalStaked -= amount;

		emit Unstaked(msg.sender, amount, reward);
	}

	function getReward(
		address user,
		uint256 amount
	) external view returns (uint256) {
		return _calculateReward(user, amount);
	}

	function _calculateReward(
		address user,
		uint256 amount
	) internal view returns (uint256) {
		uint256 stakedDuration = block.timestamp - stakingTime[user];
		uint256 rewardRate = _REWARD_RATE;
		uint256 reward = (amount * stakedDuration * rewardRate) / 1e18;
		uint256 maxReward = balanceOf(address(this)) - totalStaked;

		if (reward > maxReward) {
			reward = maxReward;
		}

		return reward;
	}

	function getTotalStaked() external view returns (uint256) {
		return totalStaked;
	}

	function getAPY() external view returns (uint256) {
		uint256 secondsInYear = 31536000;
		return (_REWARD_RATE * secondsInYear * 10000) / 1e18;
	}
}
