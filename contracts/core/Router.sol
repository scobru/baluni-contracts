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
import "./Stake.sol";

interface IOracle {
	function getRate(
		IERC20 srcToken,
		IERC20 dstToken,
		bool useWrappers
	) external view returns (uint256 weightedRate);
}

contract Router is Ownable, ERC20, Stake, ReentrancyGuard {
	using SafeERC20 for IERC20;

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

	/**
	 * @dev Initializes the Router contract.
	 *
	 * It sets the contract owner, token name, token symbol, and initializes the staking mechanism.
	 * Additionally, it mints an initial supply of tokens to the contract address, updates the rewards,
	 * adds a staked balance to the contract address, and updates the reward index if the supply is greater than zero.
	 */
	constructor()
		Ownable(msg.sender)
		ERC20("Baluni", "BALUNI")
		Stake(address(this), address(this))
	{
		_mint(address(this), 1 * 1e18);
		_updateRewards(address(this));

		balanceStakedOf[address(this)] += 0.1 * 1e18;
		supply += 1 * 1e18;

		if (supply > 0) {
			updateRewardIndex(0.9 * 1e18);
		}
	}

	function updateReward(uint256 reward) external onlyOwner {
		require(supply > 0, "No Staking Supply");
		updateRewardIndex(reward);
	}

	/**
	 * @dev Returns an array of all token addresses.
	 * @return An array of token addresses.
	 */
	function listAllTokens() external view returns (address[] memory) {
		return tokens.values();
	}

	/**
	 * @dev Returns the agent address for a given user address.
	 * @param _user The user address.
	 * @return The agent address.
	 */
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

	/**
	 * @dev This contract contains functions related to creating and interacting with agents.
	 */
	function getOrCreateAgent(address user) private returns (Agent) {
		bytes32 salt = keccak256(abi.encodePacked(user));
		if (address(userAgents[user]) == address(0)) {
			Agent agent = new Agent{ salt: salt }(user, address(this));
			// Ensure that the contract is actually deployed
			require(
				isContract(address(agent)),
				"Agent creation failed, not a contract"
			);

			userAgents[user] = agent;
			emit AgentCreated(user, address(agent));
		}
		return userAgents[user];
	}

	/**
	 * @dev Checks if the given address is a contract.
	 * @param _addr The address to check.
	 * @return A boolean indicating whether the address is a contract or not.
	 */
	function isContract(address _addr) private view returns (bool) {
		uint32 size;
		assembly {
			size := extcodesize(_addr)
		}
		return size > 0;
	}

	/**
	 * @dev Gets the bytecode of the Agent contract with the specified owner.
	 * @param _owner The owner address.
	 * @return The bytecode of the Agent contract.
	 */
	function getBytecode(address _owner) internal view returns (bytes memory) {
		require(_owner != address(0), "Owner address cannot be zero.");
		bytes memory bytecode = type(Agent).creationCode;
		return abi.encodePacked(bytecode, abi.encode(_owner, address(this)));
	}

	/**
	 * @dev Returns the basis points fee value.
	 * @return The basis points fee value.
	 */
	function getBpsFee() external view returns (uint256) {
		return _BPS_FEE;
	}

	/**
	 * @dev Changes the basis points fee value.
	 * @param _newFee The new basis points fee value.
	 */
	function changeBpsFee(uint256 _newFee) external onlyOwner {
		_BPS_FEE = _newFee;
		emit ChangeBpsFee(_newFee);
	}

	/**
	 * @dev Changes the liquidation prize value.
	 * @param _newPrice The new liquidation prize value.
	 */
	function changeLiquidationPrize(uint256 _newPrice) external onlyOwner {
		_LIQ_PRIZE = _newPrice;
		emit ChangeLiquidationPrize(_newPrice);
	}

	/**
	 * @dev Executes a series of calls and transfers tokens to the caller based on the result.
	 * @param calls An array of Agent.Call structs representing the calls to be executed.
	 * @param tokensReturn An array of addresses representing the tokens to be returned to the caller.
	 */
	function execute(
		Agent.Call[] calldata calls,
		address[] calldata tokensReturn
	) external nonReentrant {
		Agent agent = getOrCreateAgent(msg.sender);

		bool[] memory isTokenNew = new bool[](tokensReturn.length);

		for (uint256 i = 0; i < tokensReturn.length; i++) {
			isTokenNew[i] = !EnumerableSet.contains(tokens, tokensReturn[i]);
		}

		agent.execute(calls, tokensReturn);

		for (uint256 i = 0; i < tokensReturn.length; i++) {
			address token = tokensReturn[i];

			address poolNative3000 = uniswapFactory.getPool(
				tokensReturn[i],
				address(WNATIVE),
				3000
			);

			address poolNative500 = uniswapFactory.getPool(
				tokensReturn[i],
				address(WNATIVE),
				500
			);

			bool poolExist = poolNative3000 != address(0) ||
				poolNative500 != address(0);

			if (isTokenNew[i] && poolExist) {
				EnumerableSet.add(tokens, tokensReturn[i]);
			}

			if (!poolExist) {
				uint256 balance = IERC20(token).balanceOf(address(this));
				setApproval(token, msg.sender, balance);
				IERC20(token).transfer(msg.sender, balance);
			}
		}
	}

	/**
	 * @dev Converts the specified token to USDC.
	 * @param token The address of the token to be converted.
	 * @notice This function is external and can only be called once per transaction.
	 * @notice The contract must have sufficient allowance to spend the specified token.
	 * @notice If the contract's balance of the specified token is greater than the allowance, the contract will set the allowance to the total balance.
	 * @notice The function performs a single swap from the specified token to USDC using the Uniswap router.
	 * @notice If the swap is successful and the resulting amount is greater than zero, the function performs a multi-hop swap from the specified token to USDC using the Uniswap router.
	 * @notice If the multi-hop swap fails, the function reverts with an error message.
	 * @notice After the swaps, the function mints a specified amount of tokens to the message sender and emits a Mint event.
	 */
	function convertTokenToUSDC(address token) external nonReentrant {
		uint totalERC20Balance = IERC20(token).balanceOf(address(this));

		uint allowance = IERC20(token).allowance(
			address(this),
			address(uniswapRouter)
		);

		setApproval(token, address(uniswapRouter), totalERC20Balance);

		address pool = uniswapFactory.getPool(token, address(USDC), 3000);

		if (pool != address(0)) {
			singleSwap(token, address(USDC), totalERC20Balance, address(this));
		} else {
			uint256 amountOutHop = multiHopSwap(
				token,
				address(WNATIVE),
				address(USDC),
				totalERC20Balance,
				address(this)
			);
			require(amountOutHop > 0, "Swap Failed, Try Burn()");
		}

		uint reward = claimTo(msg.sender);
		emit Mint(msg.sender, reward);
	}

	/**
	 * @dev Burns a specified amount of BAL tokens from the caller's balance.
	 * The caller must have a balance of at least `amount` BAL tokens.
	 * The function calculates the share of each token held by the contract based on the total supply of BAL tokens and the balance of each token.
	 * It transfers the proportional share of each token to the caller and burns the specified amount of BAL tokens.
	 * Emits a `Burn` event with the caller's address and the burned amount.
	 *
	 * Requirements:
	 * - The caller must have a balance of at least `amount` BAL tokens.
	 *
	 * @param amount The amount of BAL tokens to burn.
	 */
	function burn(uint amount) external nonReentrant {
		require(balanceOf(msg.sender) >= amount, "Insufficient BAL");

		for (uint256 i; i < tokens.length(); i++) {
			address token = tokens.at(i);
			uint totalBaluni = totalSupply();
			uint totalERC20Balance = IERC20(token).balanceOf(address(this));
			uint256 decimals = IERC20Metadata(token).decimals();
			uint share = _calculateTokenShare(
				totalBaluni,
				totalERC20Balance,
				amount,
				decimals
			);
			setApproval(token, msg.sender, share);
			IERC20(token).transfer(msg.sender, share);
		}
		_burn(msg.sender, amount);
		emit Burn(msg.sender, amount);
	}

	/**
	 * @dev Burns tokens and swaps them to USDC.
	 * @param amount The amount of tokens to burn.
	 * Requirements:
	 * - `amount` must be greater than 0.
	 * - The contract must have sufficient BAL tokens.
	 * - The contract must have sufficient balance of each token in the `tokens` array.
	 * - The `token` must implement the ERC20 interface.
	 * - The `token` must implement the ERC20Metadata interface.
	 * - The `token` must have a valid `decimals` value.
	 * - The `USDC` and `WNATIVE` addresses must be valid.
	 * - The `singleSwap` and `multiHopSwap` functions must successfully execute the swaps.
	 * - The `token` must be successfully transferred to `msg.sender`.
	 * - The `amount` must be successfully burned from `msg.sender`.
	 * Emits a `Burn` event with the `msg.sender` and `amount`.
	 */
	function burnTokensAndSwapToUSDC(uint amount) external nonReentrant {
		require(amount > 0, "Insufficient BAL");

		for (uint256 i; i < tokens.length(); i++) {
			address token = tokens.at(i);

			uint totalBaluni = totalSupply();
			uint totalERC20Balance = IERC20(token).balanceOf(address(this));

			uint256 decimals = IERC20Metadata(token).decimals();

			uint burnAmount = _calculateTokenShare(
				totalBaluni,
				totalERC20Balance,
				amount,
				decimals
			);

			address pool = uniswapFactory.getPool(token, address(USDC), 3000);

			if (pool != address(0)) {
				singleSwap(token, address(USDC), burnAmount, msg.sender);
			} else {
				uint256 amountOutHop = multiHopSwap(
					token,
					address(WNATIVE),
					address(USDC),
					burnAmount,
					msg.sender
				);
				require(amountOutHop > 0, "Swap Failed, Try Burn()");
			}
		}
		_burn(msg.sender, amount);
		emit Burn(msg.sender, amount);
	}

	/**
	 * @dev Calculates the net amount after deducting the fee.
	 * @param _amount The input amount.
	 * @return The net amount after deducting the fee.
	 */
	function calculateNetAmountAfterFee(
		uint256 _amount
	) public view returns (uint256) {
		uint256 amountInWithFee = (_amount * (10000 - (_BPS_FEE))) / 10000;
		return amountInWithFee;
	}

	/**
	 * @dev Returns the unit price for burning.
	 * @return The unit price for burning.
	 */
	function getUnitPrice() public view returns (uint256) {
		return _calculateProportionalUSDCShare(1e18);
	}

	/**
	 * @dev Mints tokens to the caller.
	 * @param amount The amount of tokens to mint.
	 */
	function mint(uint256 amount) external nonReentrant returns (uint256) {
		require(amount > 0, "Amount must be greater than zero");

		uint balance = IERC20(USDC).balanceOf(msg.sender);
		require(amount > 0, "Amount must be greater than zero");
		require(balance >= amount, "Amount must be greater than balance");

		uint256 allowed = USDC.allowance(msg.sender, address(this));
		require(allowed >= amount, "Check the token allowance");

		USDC.safeTransferFrom(msg.sender, address(this), amount);

		uint256 totalUSDValuation = calculateTotalUSDCValuation();

		uint toMint = ((totalSupply() / 1e12) * (amount)) /
			(totalUSDValuation / 1e12);

		uint256 amountInWithFee = calculateNetAmountAfterFee(toMint * 1e12);

		require(
			amountInWithFee > 0,
			"AmountInWithFee must be greater than zero"
		);

		uint256 feeAmount = toMint * 1e12 - amountInWithFee;

		_mint(address(this), feeAmount);
		_mint(msg.sender, amountInWithFee);

		emit Mint(address(this), feeAmount);
		emit Mint(msg.sender, amountInWithFee);

		if (supply > 0) {
			updateRewardIndex(feeAmount);
		}

		return amountInWithFee;
	}

	/**
	 * @dev Calculates the proportional USDC share for a given BAL amount.
	 * @param amount The amount of BAL tokens.
	 * @return The proportional USDC share.
	 */
	function _calculateProportionalUSDCShare(
		uint amount
	) internal view returns (uint) {
		uint totalBaluni = totalSupply();
		require(totalBaluni > 0, "Total supply cannot be zero");
		uint totalUSDC = calculateTotalUSDCValuation();
		return ((amount * totalUSDC) / totalBaluni);
	}

	/**
	 * @dev Calculates the token share for a given amount of tokens.
	 * @param totalBaluni The total supply of BAL tokens.
	 * @param totalERC20Balance The total balance of the ERC20 token.
	 * @param amount The amount of tokens.
	 * @param tokenDecimals The number of decimals of the token.
	 * @return The token share.
	 */
	function _calculateTokenShare(
		uint totalBaluni,
		uint totalERC20Balance,
		uint amount,
		uint tokenDecimals
	) internal pure returns (uint256) {
		require(totalBaluni > 0, "Total supply cannot be zero");

		uint share;

		if (tokenDecimals != 18) {
			amount = amount * (10 ** (18 - tokenDecimals));
			uint256 balance = totalERC20Balance * (10 ** (18 - tokenDecimals));
			share = (amount * balance) / totalBaluni;
		} else {
			share = (amount * totalERC20Balance) / totalBaluni;
		}

		return share;
	}

	/**
	 * @dev Calculates the valuation of a given token amount.
	 * @param amount The amount of tokens to calculate the valuation for.
	 * @param token The address of the token.
	 * @return The valuation of the token amount.
	 */
	function _calculateTokenValuation(
		uint amount,
		address token
	) internal view returns (uint256) {
		uint valuation;
		uint256 tokenDecimal = IERC20Metadata(token).decimals();
		if (token == address(USDC)) return amount * 1e12;

		try IOracle(oracle).getRate(IERC20(token), IERC20(USDC), false) {
			if (tokenDecimal == 8) {
				uint formattedAmount = amount * 1 ** (18 - tokenDecimal);
				uint usdRate = IOracle(oracle).getRate(
					IERC20(token),
					IERC20(USDC),
					false
				) * 1e2;
				valuation = (formattedAmount * usdRate) / 1e18;
			} else if (tokenDecimal == 6) {
				uint formattedAmount = amount * 1 ** (18 - tokenDecimal);
				uint usdRate = IOracle(oracle).getRate(
					IERC20(token),
					IERC20(USDC),
					false
				);
				valuation = (formattedAmount * usdRate) / 1e18;
			} else {
				uint usdRate = IOracle(oracle).getRate(
					IERC20(token),
					IERC20(USDC),
					false
				) * 1e12;
				valuation = (amount * usdRate) / 1e18;
			}
		} catch {
			valuation = 0;
		}

		return valuation;
	}

	/**
	 * @dev Calculates the total USDC valuation of all tokens held by the contract.
	 * @return The total USDC valuation.
	 */

	function calculateTotalUSDCValuation() public view returns (uint) {
		uint totalValuation;

		for (uint256 i; i < tokens.length(); i++) {
			address token = tokens.at(i);
			uint256 balance = IERC20(token).balanceOf(address(this));

			uint256 tokenBalanceValuation = _calculateTokenValuation(
				balance,
				token
			);

			totalValuation += tokenBalanceValuation;
		}

		return totalValuation;
	}

	/**
	 * @dev Returns the value of a given BAL token amount in USDC.
	 * @param amount The amount of BAL tokens.
	 * @return The value of the BAL tokens in USDC.
	 */
	function getUSDCShareValue(uint amount) external view returns (uint) {
		return _calculateProportionalUSDCShare(amount);
	}

	/**
	 * @dev Performs a single token swap on Uniswap.
	 * @param token The address of the token to swap.
	 * @param stableToken The address of the stable token to receive.
	 * @param tokenBalance The balance of the token to swap.
	 * @param receiver The address to receive the swapped tokens.
	 * @return amountOut The amount of stable tokens received.
	 */
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

	/**
	 * @dev Performs a multi-hop swap using the Uniswap router.
	 * @param token The address of the token to swap.
	 * @param intermediateToken The address of the intermediate token to swap through.
	 * @param stableToken The address of the stable token to receive.
	 * @param tokenBalance The balance of the token to swap.
	 * @param receiver The address to receive the swapped tokens.
	 * @return amountOut The amount of stable tokens received.
	 */
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

	/**
	 * @dev Adjusts the amount by multiplying it with 10^(18 - decimals).
	 * @param amount The original amount.
	 * @param decimals The number of decimals of the token.
	 * @return The adjusted amount.
	 */
	function getDecimalAdjustedAmount(
		uint256 amount,
		uint256 decimals
	) internal pure returns (uint256) {
		return amount * (10 ** (18 - decimals));
	}

	/**
	 * @dev Sets the approval of a token for a spender.
	 * @param token The address of the token to approve.
	 * @param spender The address of the spender.
	 * @param amount The amount to approve.
	 */
	function setApproval(
		address token,
		address spender,
		uint256 amount
	) internal {
		IERC20 _token = IERC20(token);
		uint256 currentAllowance = _token.allowance(address(this), spender);

		if (currentAllowance > 0) {
			if (currentAllowance < amount) {
				_token.approve(spender, amount);
			}
		}
	}
}
