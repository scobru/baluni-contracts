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
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

import "./BaluniAgent.sol";
import "./BaluniStake.sol";

interface IOracle {
	function getRate(
		IERC20 srcToken,
		IERC20 dstToken,
		bool useWrappers
	) external view returns (uint256 weightedRate);
}

contract BaluniRouter is Ownable, ERC20, BaluniStake {
	using SafeERC20 for IERC20;

	uint256 public constant _MAX_BPS_FEE = 500;

	uint256 public _BPS_FEE = 30; // 0.3%.
	uint256 public _BPS_BASE = 10000;
	uint256 public _BPS_LIQUIDATE_FEE = 30; // 0.3%.

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

	mapping(address => BaluniAgent) public userAgents;
	mapping(address => uint256) public tokenBalanceMap;

	event AgentCreated(address user, address agent);
	event Execute(
		address user,
		BaluniAgent.Call[] calls,
		address[] tokensReturn
	);
	event Burn(address user, uint256 value);
	event Mint(address user, uint256 value);
	event ChangeBpsFee(uint256 newFee);
	event ChangeLiquidateFee(uint256 newFee);

	modifier validTimestamp(uint256 _timestamp) {
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

	constructor()
		Ownable(msg.sender)
		ERC20("Baluni", "BALUNI")
		BaluniStake(address(this), address(this))
	{
		_mint(address(this), 1 ether);
		_stakeToContract(address(this), 1 ether);
		_updateRewards(address(this));

		EnumerableSet.add(tokens, address(USDC));
	}

	function _stakeToContract(address _to, uint256 _amount) internal {
		balanceStakedOf[_to] += _amount;
		stakingSupply += _amount;
		stakeTimestamp[msg.sender] = block.timestamp;

		if (stakingSupply > 0) {
			updateRewardIndex(_amount);
		}
	}

	function listAllTokens() external view returns (address[] memory) {
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

		return address(uint160(uint256(hash)));
	}

	function getOrCreateAgent(address user) private returns (BaluniAgent) {
		bytes32 salt = keccak256(abi.encodePacked(user));

		if (address(userAgents[user]) == address(0)) {
			BaluniAgent agent = new BaluniAgent{ salt: salt }(
				user,
				address(this)
			);
			require(
				isContract(address(agent)),
				"Agent creation failed, not a contract"
			);
			userAgents[user] = agent;
			emit AgentCreated(user, address(agent));
		}
		return userAgents[user];
	}

	function isContract(address _addr) private view returns (bool) {
		uint32 size;
		assembly {
			size := extcodesize(_addr)
		}
		return size > 0;
	}

	function getBytecode(address _owner) internal view returns (bytes memory) {
		require(_owner != address(0), "Owner address cannot be zero.");
		bytes memory bytecode = type(BaluniAgent).creationCode;
		return abi.encodePacked(bytecode, abi.encode(_owner, address(this)));
	}

	function getBpsFee() external view returns (uint256) {
		return _BPS_FEE;
	}

	function changeBpsFee(uint256 _newFee) external onlyOwner {
		_BPS_FEE = _newFee;
		emit ChangeBpsFee(_newFee);
	}

	function changeBpsLiquidateFee(uint256 _newFee) external onlyOwner {
		_BPS_LIQUIDATE_FEE = _newFee;
		emit ChangeLiquidateFee(_newFee);
	}

	function execute(
		BaluniAgent.Call[] calldata calls,
		address[] calldata tokensReturn
	) external nonReentrant {
		BaluniAgent agent = getOrCreateAgent(msg.sender);
		bool[] memory isTokenNew = new bool[](tokensReturn.length);

		for (uint256 i = 0; i < tokensReturn.length; i++) {
			isTokenNew[i] = !EnumerableSet.contains(tokens, tokensReturn[i]);
		}

		agent.execute(calls, tokensReturn);

		for (uint256 i = 0; i < tokensReturn.length; i++) {
			address token = tokensReturn[i];
			address poolNative3000 = uniswapFactory.getPool(
				token,
				address(WNATIVE),
				3000
			);
			address poolNative500 = uniswapFactory.getPool(
				token,
				address(WNATIVE),
				500
			);
			bool poolExist = poolNative3000 != address(0) ||
				poolNative500 != address(0);

			if (isTokenNew[i] && poolExist) {
				EnumerableSet.add(tokens, token);
			}

			if (!poolExist) {
				uint256 balance = IERC20(token).balanceOf(address(this));
				IERC20(token).transfer(msg.sender, balance);
			}
		}
	}

	function liquidate(address token) external nonReentrant {
		uint256 totalERC20Balance = IERC20(token).balanceOf(address(this));
		address pool = uniswapFactory.getPool(token, address(USDC), 3000);
		secureApproval(token, address(uniswapRouter), totalERC20Balance);

		if (pool != address(0)) {
			uint256 singleSwapResult = singleSwap(
				token,
				address(USDC),
				totalERC20Balance,
				address(this)
			);
			require(singleSwapResult > 0, "Swap Failed, Try Burn()");
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

		uint256 reward = claimTo(address(this), msg.sender);
		uint256 mintAmount = (totalSupply() * _BPS_LIQUIDATE_FEE) / 10000;

		_mint(address(this), mintAmount);
		_stakeToContract(address(this), mintAmount);

		emit Mint(address(this), mintAmount);
		emit RewardClaimed(msg.sender, reward);
	}

	function burn(uint256 burnAmount) external nonReentrant {
		require(balanceOf(msg.sender) >= burnAmount, "Insufficient BAL");

		for (uint256 i; i < tokens.length(); i++) {
			address token = tokens.at(i);
			uint256 totalBaluni = totalSupply();
			uint256 totalERC20Balance = IERC20(token).balanceOf(address(this));

			if (totalERC20Balance == 0 || token == address(this)) continue;

			uint256 decimals = IERC20Metadata(token).decimals();
			uint256 share = _calculateTokenShare(
				totalBaluni,
				totalERC20Balance,
				burnAmount,
				decimals
			);

			IERC20(token).transfer(msg.sender, share);
		}
		_burn(msg.sender, burnAmount);
		emit Burn(msg.sender, burnAmount);
	}

	function burnTokensAndSwapToUSDC(uint256 burnAmount) external nonReentrant {
		require(burnAmount > 0, "Insufficient BAL");

		for (uint256 i; i < tokens.length(); i++) {
			address token = tokens.at(i);
			uint256 totalBaluni = totalSupply();
			uint256 totalERC20Balance = IERC20(token).balanceOf(address(this));

			if (totalERC20Balance > 0 == false) continue;
			if (token == address(this)) continue;

			uint256 decimals = IERC20Metadata(token).decimals();
			uint256 burnAmountToken = _calculateTokenShare(
				totalBaluni,
				totalERC20Balance,
				burnAmount,
				decimals
			);

			if (token == address(USDC)) {
				IERC20(USDC).transfer(msg.sender, burnAmountToken);
				continue;
			}

			address pool = uniswapFactory.getPool(token, address(USDC), 3000);
			secureApproval(token, address(uniswapRouter), burnAmountToken);

			if (pool != address(0)) {
				singleSwap(token, address(USDC), burnAmountToken, msg.sender);
			} else {
				uint256 amountOutHop = multiHopSwap(
					token,
					address(WNATIVE),
					address(USDC),
					burnAmountToken,
					msg.sender
				);
				require(amountOutHop > 0, "Swap Failed, Try Burn()");
			}
		}
		_burn(msg.sender, burnAmount);

		emit Burn(msg.sender, burnAmount);
	}

	function calculateNetAmountAfterFee(
		uint256 _amount
	) internal view returns (uint256) {
		uint256 amountInWithFee = (_amount * (_BPS_BASE - (_BPS_FEE))) /
			_BPS_BASE;
		return amountInWithFee;
	}

	function getUnitPrice() public view returns (uint256) {
		return _calculateBaluniToUsdc(1e18);
	}

	function mintUSDC(
		uint256 balAmountToMint
	) public nonReentrant returns (uint256) {
		uint256 totalUSDValuation = _totalValuation();
		uint256 totalBalSupply = totalSupply();
		uint256 usdcRequired = (balAmountToMint * totalUSDValuation) /
			totalBalSupply;
		uint256 balance = IERC20(USDC).balanceOf(msg.sender);
		require(totalBalSupply > 0, "Total BALUNI supply cannot be zero");
		require(balance >= usdcRequired / 1e12, "USDC balance is insufficient");

		uint256 allowed = USDC.allowance(msg.sender, address(this));
		require(allowed >= usdcRequired / 1e12, "Check the token allowance");

		USDC.safeTransferFrom(msg.sender, address(this), usdcRequired / 1e12);

		uint256 amountAfterFee = calculateNetAmountAfterFee(balAmountToMint);
		uint256 netBalAmountToMint = balAmountToMint - amountAfterFee;

		_mint(address(this), netBalAmountToMint);
		emit Mint(address(this), netBalAmountToMint);

		if (stakingSupply > 0) {
			updateRewardIndex(netBalAmountToMint);
		}

		_mint(msg.sender, amountAfterFee);
		emit Mint(msg.sender, amountAfterFee);

		return netBalAmountToMint;
	}

	function mintERC20(
		uint256 balAmountToMint,
		address asset
	) public nonReentrant returns (uint256) {
		uint256 totalUSDValuation = _totalValuation();
		uint256 totalBalSupply = totalSupply();
		require(totalBalSupply > 0, "Total BALUNI supply cannot be zero");

		uint256 usdcRequired = (balAmountToMint * totalUSDValuation) /
			totalBalSupply;

		uint8 decimalA = IERC20Metadata(address(USDC)).decimals();
		uint8 decimalB = IERC20Metadata(asset).decimals();

		uint256 assetRate = oracle.getRate(IERC20(USDC), IERC20(asset), false);
		uint256 required;

		if (decimalB > decimalA) {
			uint256 rate = assetRate / 10 ** (decimalB - decimalA);
			required = (usdcRequired / rate) * 1e18;
			required = required / 10 ** (decimalB - decimalA);
		} else {
			uint256 rate = assetRate * 10 ** (decimalA - decimalB);
			required = (usdcRequired / rate) * 1e18;
			required = required / 10 ** (decimalA - decimalB);
		}

		uint256 balance = IERC20(asset).balanceOf(msg.sender);

		require(balance >= required, "Balance is insufficient");

		uint256 allowed = IERC20(asset).allowance(msg.sender, address(this));

		require(allowed >= required, "Check the token allowance");

		IERC20(asset).safeTransferFrom(msg.sender, address(this), required);

		uint256 amountAfterFee = calculateNetAmountAfterFee(balAmountToMint);
		uint256 netBalAmountToMint = balAmountToMint - amountAfterFee;

		_mint(address(this), netBalAmountToMint);
		emit Mint(address(this), netBalAmountToMint);

		if (stakingSupply > 0) {
			updateRewardIndex(netBalAmountToMint);
		}

		_mint(msg.sender, amountAfterFee);
		emit Mint(msg.sender, amountAfterFee);

		return amountAfterFee;
	}

	function _calculateBaluniToUsdc(
		uint256 amount
	) internal view returns (uint256 shareUSDC) {
		uint256 totalBaluni = totalSupply();
		require(totalBaluni > 0, "Total supply cannot be zero");
		uint256 totalUSDC = _totalValuation();
		shareUSDC = (amount * totalUSDC) / totalBaluni;
	}

	function _calculateTokenShare(
		uint256 totalBaluni,
		uint256 totalERC20Balance,
		uint256 amount,
		uint256 tokenDecimals
	) internal pure returns (uint256) {
		require(totalBaluni > 0, "Total supply cannot be zero");
		uint256 rate;

		if (tokenDecimals < 18) {
			rate =
				((amount * totalERC20Balance)) /
				(totalBaluni / (10 ** (18 - tokenDecimals)));
		} else {
			rate = (amount * totalERC20Balance) / totalBaluni;
		}

		return rate;
	}

	function _calculateTokenValuation(
		uint256 amount,
		address token
	) internal view returns (uint256 valuation) {
		uint256 rate;
		uint8 tokenDecimal = IERC20Metadata(token).decimals();
		uint8 usdcDecimal = IERC20Metadata(address(USDC)).decimals();

		if (token == address(USDC)) return amount * 1e12;

		try
			IOracle(oracle).getRate(IERC20(token), IERC20(USDC), false)
		returns (uint256 _rate) {
			rate = _rate;
		} catch {
			return 0;
		}

		uint256 factor = (10 ** (tokenDecimal - usdcDecimal));

		rate = ((amount * factor) * (rate * factor)) / 1e18;

		return rate;
	}

	function totalValuation() external view returns (uint256) {
		return _totalValuation();
	}

	function _totalValuation() internal view returns (uint256) {
		uint256 _totalV;

		for (uint256 i; i < tokens.length(); i++) {
			address token = tokens.at(i);
			uint256 balance = IERC20(token).balanceOf(address(this));
			uint256 tokenBalanceValuation = _calculateTokenValuation(
				balance,
				token
			);
			_totalV += tokenBalanceValuation;
		}

		return _totalV;
	}

	function getUSDCShareValue(uint256 amount) external view returns (uint256) {
		return _calculateBaluniToUsdc(amount);
	}

	function performArbitrage() external nonReentrant {
		uint256 unitPrice = getUnitPrice();
		uint256 marketPrice = oracle.getRate(
			IERC20(address(this)),
			IERC20(address(USDC)),
			false
		);

		uint256 baluniBalance = balanceOf(address(this));
		uint256 usdcBalance = IERC20(USDC).balanceOf(address(this));

		if (marketPrice * 1e12 < unitPrice) {
			uint256 amountToBuy = (usdcBalance * 1e12) /
				(marketPrice * 1e12) /
				1e18;

			if (amountToBuy > baluniBalance) amountToBuy = baluniBalance;

			secureApproval(address(USDC), address(uniswapRouter), usdcBalance);

			uint256 amountOut = singleSwap(
				address(USDC),
				address(this),
				usdcBalance,
				address(this)
			);
			require(
				amountOut >= amountToBuy,
				"Arbitrage failed: insufficient output amount"
			);
			secureApproval(address(this), address(uniswapRouter), amountOut);
			singleSwap(address(this), address(USDC), amountOut, address(this));
			require(
				IERC20(USDC).balanceOf(address(this)) > usdcBalance,
				"Arbitrage did not profit"
			);
		} else if (marketPrice * 1e12 > unitPrice) {
			uint256 amountToSell = baluniBalance;
			secureApproval(address(this), address(uniswapRouter), amountToSell);
			uint256 amountOutUSDC = singleSwap(
				address(this),
				address(USDC),
				amountToSell,
				address(this)
			);
			require(
				amountOutUSDC > usdcBalance,
				"Arbitrage failed: insufficient output amount"
			);
			secureApproval(
				address(USDC),
				address(uniswapRouter),
				amountOutUSDC
			);
			singleSwap(
				address(USDC),
				address(this),
				amountOutUSDC,
				address(this)
			);
			require(
				balanceOf(address(this)) > baluniBalance,
				"Arbitrage did not profit"
			);
		}
	}

	function singleSwap(
		address token0,
		address token1,
		uint256 tokenBalance,
		address receiver
	) private returns (uint256 amountOut) {
		ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
			.ExactInputSingleParams({
				tokenIn: token0,
				tokenOut: token1,
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
		address token0,
		address token1,
		address token2,
		uint256 tokenBalance,
		address receiver
	) private returns (uint256 amountOut) {
		ISwapRouter.ExactInputParams memory params = ISwapRouter
			.ExactInputParams({
				path: abi.encodePacked(
					token0,
					uint24(3000),
					token1,
					uint24(3000),
					token2
				),
				recipient: address(receiver),
				deadline: block.timestamp,
				amountIn: tokenBalance,
				amountOutMinimum: 0
			});
		return uniswapRouter.exactInput(params);
	}

	function secureApproval(
		address token,
		address spender,
		uint256 amount
	) internal {
		IERC20 _token = IERC20(token);
		uint256 currentAllowance = _token.allowance(address(this), spender);

		if (currentAllowance != amount) {
			if (currentAllowance != 0) {
				_token.approve(spender, 0);
			}

			_token.approve(spender, amount);
		}
	}

	function rebalance(
		address[] calldata assets,
		uint256[] calldata weights
	) external returns (bool) {
		uint256 totalValue;

		for (uint256 i; i < assets.length; i++) {
			uint256 balance = IERC20(assets[i]).balanceOf(msg.sender);
			uint256 tokenValuation = _calculateTokenValuation(
				balance,
				assets[i]
			);
			totalValue += tokenValuation;
		}

		uint256[] memory overweightVaults = new uint256[](assets.length);
		uint256[] memory overweightAmounts = new uint256[](assets.length);
		uint256[] memory underweightVaults = new uint256[](assets.length);
		uint256[] memory underweightAmounts = new uint256[](assets.length);

		uint256 overweightVaultsLength;
		uint256 underweightVaultsLength;
		uint256 overweightAmount;
		uint256 overweightPercent;
		uint256 targetWeight;
		uint256 currentWeight;
		uint256 totalActiveWeight;

		bool overweight;

		for (uint256 i; i < assets.length; i++) {
			uint256 balance = IERC20(assets[i]).balanceOf(msg.sender);
			uint256 decimals = IERC20Metadata(assets[i]).decimals();
			uint256 tokensTotalValue = _calculateTokenValuation(
				balance,
				assets[i]
			);
			targetWeight = weights[i];
			currentWeight = tokensTotalValue / (10000) / (totalValue);
			overweight = currentWeight > targetWeight;
			overweightPercent = overweight
				? currentWeight - (targetWeight)
				: targetWeight - (currentWeight);
			uint256 price = _calculateTokenValuation(
				1 * 10 ** decimals,
				assets[i]
			);
			if (overweight) {
				overweightAmount = (overweightPercent * (totalValue)) / (10000);
				overweightAmount = (overweightAmount * (1e18)) / (price);
				overweightVaults[overweightVaultsLength] = i;
				overweightAmounts[overweightVaultsLength] = overweightAmount;
				overweightVaultsLength++;
			} else if (!overweight) {
				totalActiveWeight += overweightPercent;
				overweightAmount = overweightPercent;
				// overweightAmount = overweightPercent.mul(totalValue).div(10000);
				underweightVaults[underweightVaultsLength] = i;
				underweightAmounts[underweightVaultsLength] = overweightAmount;
				underweightVaultsLength++;
			}
		}

		// Resize overweightVaults and overweightAmounts to the actual overweighted vaults
		overweightVaults = _resize(overweightVaults, overweightVaultsLength);
		overweightAmounts = _resize(overweightAmounts, overweightVaultsLength);
		// Resize overweightVaults and overweightAmounts to the actual overweighted vaults
		underweightVaults = _resize(underweightVaults, underweightVaultsLength);
		underweightAmounts = _resize(
			underweightAmounts,
			underweightVaultsLength
		);

		for (uint256 i; i < overweightVaults.length; i++) {
			if (overweightAmounts[i] > 0) {
				IERC20(address(assets[overweightVaults[i]])).transferFrom(
					msg.sender,
					address(this),
					overweightAmounts[i]
				);
				address pool = uniswapFactory.getPool(
					address(assets[overweightVaults[i]]),
					address(USDC),
					3000
				);
				secureApproval(
					address(assets[overweightVaults[i]]),
					address(uniswapRouter),
					overweightAmounts[i]
				);

				if (pool != address(0)) {
					uint singleSwapResult = singleSwap(
						address(assets[overweightVaults[i]]),
						address(USDC),
						overweightAmounts[i],
						underweightVaults.length == 0
							? msg.sender
							: address(this)
					);
				} else {
					uint256 amountOutHop = multiHopSwap(
						address(assets[overweightVaults[i]]),
						address(WNATIVE),
						address(USDC),
						overweightAmounts[i],
						underweightVaults.length == 0
							? msg.sender
							: address(this)
					);
				}
			}
		}
		for (uint256 i; i < underweightVaults.length; i++) {
			if (underweightAmounts[i] > 0) {
				uint256 rebaseActiveWgt = (underweightAmounts[i] * (10000)) /
					(totalActiveWeight);

				uint256 rebBuyQty = (rebaseActiveWgt *
					IERC20(USDC).balanceOf(msg.sender) *
					1e12) / (10000);

				if (
					rebBuyQty > 0 &&
					rebBuyQty <= IERC20(USDC).balanceOf(msg.sender) * 1e12
				) {
					address pool = uniswapFactory.getPool(
						address(assets[underweightVaults[i]]),
						address(USDC),
						3000
					);
					secureApproval(
						address(assets[underweightVaults[i]]),
						address(uniswapRouter),
						underweightAmounts[i] / 1e12
					);

					if (pool != address(0)) {
						uint singleSwapResult = singleSwap(
							address(USDC),
							address(assets[underweightVaults[i]]),
							underweightAmounts[i] / 1e12,
							address(this)
						);

						uint256 amountToTransfer = calculateNetAmountAfterFee(
							singleSwapResult
						);
						IERC20(USDC).transfer(msg.sender, amountToTransfer);

						require(
							singleSwapResult > 0,
							"Swap Failed, Try Burn()"
						);
					} else {
						uint256 amountOutHop = multiHopSwap(
							address(USDC),
							address(WNATIVE),
							address(assets[underweightVaults[i]]),
							underweightAmounts[i] / 1e12,
							address(this)
						);

						uint256 amountToTransfer = calculateNetAmountAfterFee(
							amountOutHop
						);
						IERC20(USDC).transfer(msg.sender, amountToTransfer);

						require(amountOutHop > 0, "Swap Failed");
					}
				}
			}
		}
		return true;
	}

	function _resize(
		uint256[] memory arr,
		uint256 size
	) internal pure returns (uint256[] memory) {
		uint256[] memory ret = new uint256[](size);
		for (uint256 i; i < size; i++) {
			ret[i] = arr[i];
		}
		return ret;
	}
}
