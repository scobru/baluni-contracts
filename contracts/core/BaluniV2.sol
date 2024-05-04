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

import "./AgentV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Baluni is Ownable, ERC20 {
	using SafeERC20 for IERC20;
	uint256 public _BPS_FEE = 10;
	uint256 internal constant _MAX_FEE = 100;
	uint256 public _MINT_RATE = 2;
	uint256 internal constant _MIN_MINT_RATE = 2;

	IERC20 internal constant USDC =
		IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);

	mapping(address => Agent) public userAgents;

	event AgentCreated(address user, address agent);

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
		return true;
	}

	function changeMintRate(uint256 _newMintRate) external returns (bool) {
		require(msg.sender == owner(), "Only Owner");
		require(_MIN_MINT_RATE < _newMintRate, "Fee too high");
		_MINT_RATE = _newMintRate;
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
		Agent agent = getOrCreateAgent(msg.sender);
		agent.execute(calls, tokensReturn);
		uint256 usdBalance = USDC.balanceOf(address(this));
		uint256 mintAmount = (usdBalance * 1e12) / _MINT_RATE;
		_mint(msg.sender, mintAmount);
	}

	function burnBALForUSDC(uint amount) external {
		require(balanceOf(msg.sender) >= amount, "Insufficient BAL");
		_burn(msg.sender, amount);
		uint usdcAmount = _calculateUSDCShare(amount);
		USDC.transfer(msg.sender, usdcAmount);
	}

	function _calculateUSDCShare(uint balAmount) internal view returns (uint) {
		uint totalSupply = totalSupply();
		uint totalUSDCBalance = USDC.balanceOf(address(this));
		return (balAmount * totalUSDCBalance) / totalSupply;
	}

	function getShare(uint balAmount) external view returns (uint) {
		return _calculateUSDCShare(balAmount);
	}
}
