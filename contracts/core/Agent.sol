pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

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

	IERC20Metadata internal constant WNATIVE =
		IERC20Metadata(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);

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
		_chargeFees(tokensReturn);
		_returnTokens(tokensReturn);
	}

	function getRouter() public view returns (address) {
		return router;
	}

	function _chargeFees(address[] calldata tokensReturn) internal {
		uint256 amount;
		uint256 bpsFee = IRouter(router).getBpsFee();
		for (uint256 i = 0; i < tokensReturn.length; i++) {
			address token = tokensReturn[i];
			if (token == _NATIVE) {
				// Use the native balance for amount calculation as wrap will be executed later
				amount = (address(this).balance * bpsFee) / _BPS_BASE;
				// send to router
				payable(router).sendValue(amount);
			} else {
				uint256 balance = IERC20(token).balanceOf(address(this));
				amount = (balance * bpsFee) / _BPS_BASE;
				IERC20Metadata(token).safeTransfer(router, amount);
			}
		}
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
}
