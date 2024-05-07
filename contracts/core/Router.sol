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
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

import "./Agent.sol";

interface IStakingPool {
	function updateRewardIndex(uint256 reward) external;

	function stake(uint256 amount) external;
}

interface IOracle {
	function getRate(
		IERC20 srcToken,
		IERC20 dstToken,
		bool useWrappers
	) external view returns (uint256 weightedRate);
}

contract Router is Ownable, ERC20, ReentrancyGuard {
	using SafeERC20 for IERC20;
	address public stakingPool;

	uint256 public constant _MAX_BPS_FEE = 500;
	uint256 public _BPS_FEE = 300; // 10 / 10000 * 100 = 3%.
	uint256 public _LIQ_PRIZE = 0.00001 * 1e18;

	using EnumerableSet for EnumerableSet.AddressSet;

	EnumerableSet.AddressSet private tokens;

	IERC20 public constant USDC =
		IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);

	IERC20Metadata internal constant WNATIVE =
		IERC20Metadata(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);

	IOracle public immutable oracle =
		IOracle(0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8); // 1inch Spot Aggregator

	ISwapRouter public immutable uniswapRouter =
		ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

	IUniswapV3Factory public immutable uniswapFactory =
		IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

	mapping(address => Agent) public userAgents;
	mapping(address => uint256) public tokenBalanceMap;

	event AgentCreated(address user, address agent);
	event Execute(address user, Agent.Call[] calls, address[] tokensReturn);
	event Burn(address user, uint256 value);
	event Mint(address user, uint256 value);
	event ChangeBpsFee(uint256 newFee);
	event ChangeLiquidationPrize(uint256 newPrize);

	event ChangeStakingPool(address newPool);

	modifier validTimestamp(uint _timestamp) {
		require(
			_timestamp <= block.timestamp,
			"Timestamp too far in the future"
		);
		require(
			_timestamp >= block.timestamp - 1 days,
			"Timestamp too far in the past"
		);
		_;
	}

	constructor() Ownable(msg.sender) ERC20("Baluni", "BALUNI") {}

	function getTokens() external view returns (address[] memory) {
		return tokens.values();
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

	function getBytecode(address _owner) internal view returns (bytes memory) {
		require(_owner != address(0), "Owner address cannot be zero.");
		bytes memory bytecode = type(Agent).creationCode;
		return abi.encodePacked(bytecode, abi.encode(_owner, address(this)));
	}

	function getBpsFee() external view returns (uint256) {
		return _BPS_FEE;
	}

	function changeBpsFee(uint256 _newFee) external onlyOwner {
		_BPS_FEE = _newFee;
		emit ChangeBpsFee(_newFee);
	}

	function changeLiquidationPrize(uint256 _newPrice) external onlyOwner {
		_LIQ_PRIZE = _newPrice;
		emit ChangeLiquidationPrize(_newPrice);
	}

	function changeStakingPool(address _newPool) external onlyOwner {
		require(_newPool != address(0), "Staking pool address cannot be zero.");
		if (stakingPool != address(0))
			IERC20(address(this)).approve(stakingPool, 0); // Revoke existing approval
		IERC20(address(this)).approve(_newPool, 2 ** 256 - 1);
		stakingPool = _newPool;
		_mint(address(this), 0.1 * 1e18);
		IStakingPool(_newPool).stake(0.1 * 1e18);
		emit ChangeStakingPool(_newPool);
	}

	// Assumi che `tokens` sia una variabile di stato di tipo EnumerableSet.AddressSet

	function execute(
		Agent.Call[] calldata calls,
		address[] calldata tokensReturn
	) external nonReentrant {
		Agent agent = getOrCreateAgent(msg.sender);
		uint256[] memory startBalances = new uint256[](tokensReturn.length);

		// Pre-fetch token presence state to minimize storage access
		bool[] memory isTokenNew = new bool[](tokensReturn.length);

		for (uint256 i = 0; i < tokensReturn.length; i++) {
			startBalances[i] = IERC20(tokensReturn[i]).balanceOf(address(this));
			isTokenNew[i] = !EnumerableSet.contains(tokens, tokensReturn[i]);
		}

		agent.execute(calls, tokensReturn);

		uint256 totalValuation = 0;

		for (uint256 i = 0; i < tokensReturn.length; i++) {
			uint256 endBalance = IERC20(tokensReturn[i]).balanceOf(
				address(this)
			);
			uint256 diff = endBalance > startBalances[i]
				? endBalance - startBalances[i]
				: 0;

			if (diff > 0 && isTokenNew[i]) {
				uint256 usdRate;

				if (tokensReturn[i] == address(USDC)) {
					usdRate = 1;
				} else {
					usdRate = oracle.getRate(
						IERC20(tokensReturn[i]),
						IERC20(USDC),
						false
					);
				}

				if (usdRate != 0) {
					EnumerableSet.add(tokens, tokensReturn[i]);
					totalValuation += diff * usdRate;
				}
			} else if (diff > 0 && !isTokenNew[i]) {
				uint256 usdRate;

				if (tokensReturn[i] == address(USDC)) {
					usdRate = 1;
				} else {
					usdRate = oracle.getRate(
						IERC20(tokensReturn[i]),
						IERC20(USDC),
						false
					);
				}

				if (usdRate != 0) {
					totalValuation += diff * usdRate;
				}
			}
		}

		if (totalValuation > 0) {
			uint256 amountInWithFee = applyAmountInWithFee(totalValuation);
			uint256 feeAmount = totalValuation - amountInWithFee;

			_mint(address(this), feeAmount);
			emit Mint(address(this), feeAmount);

			IStakingPool(stakingPool).updateRewardIndex(feeAmount);
			_mint(msg.sender, amountInWithFee);
			emit Mint(msg.sender, amountInWithFee);
		}
	}

	function liquidate(address token) external returns (bool) {
		uint totalERC20Balance = IERC20(token).balanceOf(address(this));
		uint allowance = IERC20(token).allowance(
			address(this),
			address(uniswapRouter)
		);

		if (totalERC20Balance > allowance) {
			IERC20(token).approve(address(uniswapRouter), 2 ** 256 - 1);
		}

		uint256 amountOut = singleSwap(
			token,
			address(USDC),
			totalERC20Balance,
			msg.sender
		);

		if (amountOut > 0) {
			uint256 amountOutHop = multiHopSwap(
				token,
				address(WNATIVE),
				address(USDC),
				totalERC20Balance,
				msg.sender
			);
			require(amountOutHop > 0, "Swap Failed, Try Burn()");
		}
		_mint(msg.sender, _LIQ_PRIZE);
		emit Mint(msg.sender, _LIQ_PRIZE);
	}

	function burn(uint amount) external nonReentrant {
		require(amount > 0, "Insufficient BAL");
		for (uint256 i; i < tokens.length(); i++) {
			address token = tokens.at(i);
			uint totalBaluni = totalSupply();
			uint totalERC20Balance = IERC20(token).balanceOf(address(this));
			uint burnAmount = ((amount * totalERC20Balance) / totalBaluni) /
				1e12;
			IERC20(token).transfer(msg.sender, burnAmount);
		}
		_burn(msg.sender, amount);
	}

	function burnAndSwap(uint amount) external nonReentrant {
		require(amount > 0, "Insufficient BAL");
		for (uint256 i; i < tokens.length(); i++) {
			address token = tokens.at(i);
			uint totalBaluni = totalSupply();
			uint totalERC20Balance = IERC20(token).balanceOf(address(this));
			uint burnAmount = ((amount * totalERC20Balance) / totalBaluni) /
				1e12;
			uint256 amountOut = singleSwap(
				token,
				address(USDC),
				burnAmount,
				msg.sender
			);
			if (amountOut > 0) {
				uint256 amountOutHop = multiHopSwap(
					token,
					address(WNATIVE),
					address(USDC),
					burnAmount,
					msg.sender
				);
				require(amountOutHop > 0, "Swap Failed, Try Burn()");
			}
			IERC20(token).transfer(msg.sender, burnAmount);
		}
		_burn(msg.sender, amount);
	}

	function applyAmountInWithFee(
		uint256 _amount
	) public view returns (uint256) {
		uint256 amountInWithFee = (_amount * (10000 - (_BPS_FEE * 2))) / 10000;
		return amountInWithFee;
	}

	function getBurnUnitPrice() external view returns (uint256) {
		return _calculateShare(1e18);
	}

	function mint(uint256 amount) external {
		require(amount > 0, "Amount must be greater than zero");

		// Ensure there is enough allowance
		uint256 allowed = USDC.allowance(msg.sender, address(this));
		require(allowed >= amount, "Check the token allowance");

		USDC.safeTransferFrom(msg.sender, address(this), amount);

		uint256 amountInWithFee = applyAmountInWithFee(amount);
		uint256 feeAmount = amount - amountInWithFee;

		_mint(address(this), feeAmount * 1e12);
		emit Mint(address(this), feeAmount * 1e12);

		IStakingPool(stakingPool).updateRewardIndex(feeAmount * 1e12);
		_mint(msg.sender, amountInWithFee * 1e12);
		emit Mint(msg.sender, amountInWithFee * 1e12);
	}

	function _calculateShare(uint balAmount) internal view returns (uint) {
		uint totalBaluni = totalSupply();
		uint totalUSDC = calculateTotalValuation() * 1e12;
		return ((balAmount * totalUSDC) / totalBaluni) / 1e12;
	}

	function calculateTotalValuation() internal view returns (uint) {
		uint totalValuation;
		for (uint256 i; i < tokens.length(); i++) {
			address token = tokens.at(i);
			uint256 balance = IERC20(token).balanceOf(address(this));
			uint256 usdRate = oracle.getRate(
				IERC20(token),
				IERC20(USDC),
				false
			);
			uint256 tokenBalanceValuation = (balance * (usdRate * 1e12)) / 1e18;

			totalValuation += tokenBalanceValuation;
		}

		return totalValuation / 1e12;
	}

	function getValuation() external view returns (uint) {
		return calculateTotalValuation();
	}

	function getShare(uint balAmount) external view returns (uint) {
		return _calculateShare(balAmount);
	}

	function singleSwap(
		address token,
		address stableToken,
		uint tokenBalance,
		address receiver
	) private returns (uint amountOut) {
		ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
			.ExactInputSingleParams({
				tokenIn: address(token),
				tokenOut: stableToken,
				fee: 3000,
				recipient: address(receiver),
				deadline: block.timestamp,
				amountIn: tokenBalance,
				amountOutMinimum: 0,
				sqrtPriceLimitX96: 0
			});
		return uniswapRouter.exactInputSingle(params);
	}

	function multiHopSwap(
		address token,
		address intermediateToken,
		address stableToken,
		uint tokenBalance,
		address receiver
	) private returns (uint amountOut) {
		ISwapRouter.ExactInputParams memory params = ISwapRouter
			.ExactInputParams({
				path: abi.encodePacked(
					address(token),
					uint24(3000),
					intermediateToken,
					uint24(3000),
					stableToken
				),
				recipient: address(receiver),
				deadline: block.timestamp,
				amountIn: tokenBalance,
				amountOutMinimum: 0
			});
		return uniswapRouter.exactInput(params);
	}
}
