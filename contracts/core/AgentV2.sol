pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface IRouter {
	function getBpsFee() external view returns (uint256);
}

contract Agent {
	using SafeERC20 for IERC20;
	using Address for address payable;
	address public owner;
	address private router;
	address internal constant _NATIVE =
		0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

	IERC20 internal constant USDC =
		IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
	IERC20 internal constant WNATIVE =
		IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);

	ISwapRouter public immutable uniswapRouter =
		ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

	uint256 internal constant _DUST = 10;
	uint256 internal constant _BPS_BASE = 10_000;
	uint256 internal constant _BPS_FEE = 10;

	struct Call {
		address to;
		uint256 value;
		bytes data;
	}

	constructor(address _owner, address _router) {
		require(msg.sender == _router, "Only Router");
		owner = _owner;
		router = _router;
	}

	modifier onlyRouter() {
		require(msg.sender == router, "Callable only by the router");
		_;
	}

	function execute(
		Call[] calldata calls,
		address[] calldata tokensReturn
	) external onlyRouter {
		for (uint i = 0; i < calls.length; i++) {
			(bool success, ) = calls[i].to.call{ value: calls[i].value }(
				calls[i].data
			);
			require(success, "Batch call failed");
		}
		_swapTokensForUSDC(tokensReturn);
		_returnTokens(tokensReturn);
	}

	function getRouter() public view returns (address) {
		return router;
	}

	function _returnTokens(address[] calldata tokensReturn) internal {
		uint256 tokensReturnLength = tokensReturn.length;
		if (tokensReturnLength > 0) {
			address user = owner;
			for (uint256 i; i < tokensReturnLength; ) {
				address token = tokensReturn[i];
				if (token == _NATIVE) {
					if (address(this).balance > 0) {
						payable(user).sendValue(address(this).balance);
					}
				} else {
					uint256 balance = IERC20(token).balanceOf(address(this));
					if (balance > _DUST) {
						IERC20(token).safeTransfer(user, balance);
					}
				}

				unchecked {
					++i;
				}
			}
		}
	}

	function _swapTokensForUSDC(
		address[] calldata tokens
	) internal returns (uint totalUSDC) {
		uint256 routerBpsFee = IRouter(router).getBpsFee();

		totalUSDC = 0;
		address usdcAddress = address(USDC);
		address intermediateToken = address(WNATIVE);

		for (uint i = 0; i < tokens.length; i++) {
			IERC20 token = IERC20(tokens[i]);
			uint tokenBalance = token.balanceOf(address(this));
			uint amount = (tokenBalance * routerBpsFee) / _BPS_BASE;

			if (tokens[i] == usdcAddress) {
				totalUSDC += tokenBalance;
				token.safeTransfer(router, amount);
			}

			if (amount > 0) {
				token.approve(address(uniswapRouter), amount);

				uint usdcAmount = 0;
				(
					bool directSwapSuccess,
					bytes memory directSwapResult
				) = address(this).call(
						abi.encodeWithSignature(
							"singleSwap(address,address,uint256)",
							tokens[i],
							usdcAddress,
							amount
						)
					);
				if (directSwapSuccess) {
					usdcAmount = abi.decode(directSwapResult, (uint));
				} else {
					// Tentativo di swap multihop
					(
						bool multiHopSwapSuccess,
						bytes memory multiHopSwapResult
					) = address(this).call(
							abi.encodeWithSignature(
								"multiHopSwap(address,address,address,uint256)",
								tokens[i],
								intermediateToken,
								usdcAddress,
								amount
							)
						);
					if (multiHopSwapSuccess) {
						usdcAmount = abi.decode(multiHopSwapResult, (uint));
					} else {
						token.safeTransfer(owner, amount);
					}
				}
				totalUSDC += usdcAmount;
				token.approve(address(uniswapRouter), 0);
			}
		}

		return totalUSDC;
	}

	function singleSwap(
		IERC20 token,
		address usdcAddress,
		uint tokenBalance
	) private returns (uint usdcAmount) {
		ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
			.ExactInputSingleParams({
				tokenIn: address(token),
				tokenOut: usdcAddress,
				fee: 3000,
				recipient: address(router),
				deadline: block.timestamp,
				amountIn: tokenBalance,
				amountOutMinimum: 0,
				sqrtPriceLimitX96: 0
			});
		return uniswapRouter.exactInputSingle(params);
	}

	function multiHopSwap(
		IERC20 token,
		address intermediateToken,
		address usdcAddress,
		uint tokenBalance
	) private returns (uint usdcAmount) {
		ISwapRouter.ExactInputParams memory params = ISwapRouter
			.ExactInputParams({
				path: abi.encodePacked(
					address(token),
					uint24(3000),
					intermediateToken,
					uint24(3000),
					usdcAddress
				),
				recipient: address(router),
				deadline: block.timestamp,
				amountIn: tokenBalance,
				amountOutMinimum: 0
			});
		return uniswapRouter.exactInput(params);
	}
}
