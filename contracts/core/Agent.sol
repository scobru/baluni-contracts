pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

interface IRouter {
	function getBpsFee() external view returns (uint256);
}

contract Agent {
	using SafeERC20 for IERC20Metadata;
	using Address for address payable;
	address public owner;
	address private router;
	address internal constant _NATIVE =
		0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

	IERC20Metadata internal constant USDC =
		IERC20Metadata(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
	IERC20Metadata internal constant WNATIVE =
		IERC20Metadata(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);

	ISwapRouter public immutable uniswapRouter =
		ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
	IUniswapV3Factory public immutable uniswapFactory =
		IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

	uint256 internal constant _DUST = 10;
	uint256 internal constant _BPS_BASE = 10000;

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
			for (uint256 i; i < tokensReturnLength; ) {
				address token = tokensReturn[i];
				if (token == _NATIVE) {
					if (address(this).balance > 0) {
						payable(owner).sendValue(address(this).balance);
					}
				} else {
					uint256 balance = IERC20Metadata(token).balanceOf(
						address(this)
					);
					if (balance > _DUST) {
						IERC20Metadata(token).safeTransfer(owner, balance);
					}
				}

				unchecked {
					++i;
				}
			}
		}
	}

	function _swapTokensForUSDC(address[] calldata tokens) internal {
		uint256 routerBpsFee = IRouter(router).getBpsFee();

		for (uint i = 0; i < tokens.length; i++) {
			IERC20Metadata token = IERC20Metadata(tokens[i]);
			uint tokenBalance = token.balanceOf(address(this));

			if (tokenBalance == 0) {
				continue;
			}

			uint amountAfterFee = (tokenBalance * routerBpsFee) / _BPS_BASE;

			require(amountAfterFee <= tokenBalance, "Wrong AmountAfterFee");

			if (address(token) == address(USDC)) {
				token.transfer(router, amountAfterFee);
				continue;
			}

			if (amountAfterFee == 0) continue;

			token.approve(address(uniswapRouter), amountAfterFee);

			address poolTokenUSDC = uniswapFactory.getPool(
				address(token),
				address(USDC),
				3000
			);
			address poolTokenWNATIVE = uniswapFactory.getPool(
				address(token),
				address(WNATIVE),
				3000
			);

			// Se non esiste un pool per nessuno di questi, continua al token successivo.
			if (poolTokenUSDC == address(0) && poolTokenWNATIVE == address(0))
				continue;

			(bool directSwapSuccess, ) = address(this).call(
				abi.encodeWithSignature(
					"singleSwap(address,address,uint256)",
					address(token),
					address(USDC),
					amountAfterFee
				)
			);
			if (directSwapSuccess) {
				continue;
			} else {
				(bool multiHopSwapSuccess, ) = address(this).call(
					abi.encodeWithSignature(
						"multiHopSwap(address,address,address,uint256)",
						address(token),
						address(WNATIVE),
						address(USDC),
						amountAfterFee
					)
				);
				if (multiHopSwapSuccess) {
					continue;
				} else {
					token.transfer(owner, amountAfterFee); // Se entrambi gli swap falliscono
				}
			}
			token.approve(address(uniswapRouter), 0); // Revoca l'approvazione dopo lo swap
		}
	}

	function singleSwap(
		IERC20Metadata token,
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
		IERC20Metadata token,
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
