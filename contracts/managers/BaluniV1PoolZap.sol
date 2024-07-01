// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

import '../interfaces/IBaluniV1Registry.sol';
import '../interfaces/IBaluniV1Swapper.sol';

interface IBaluniV1Pool {
    function deposit(address to, uint256[] memory amounts, uint256 deadline) external returns (uint256);
    function withdraw(uint256 share, address to, uint256 deadline) external returns (uint256);
    function getAssets() external view returns (address[] memory);
    function getReserves() external view returns (uint256[] memory);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

contract BaluniV1PoolZap is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable {
    IBaluniV1Registry public registry;
    IBaluniV1Swapper public baluniSwapper;
    address public WETH9;

    function initialize(address _registry) public initializer {
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        registry = IBaluniV1Registry(_registry);
        baluniSwapper = IBaluniV1Swapper(registry.getBaluniSwapper());
        WETH9 = registry.getWNATIVE();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    receive() external payable {}

    function zapIn(
        address poolAddress,
        address tokenIn,
        uint256 amountIn,
        uint256 minAmountsOut,
        address receiver
    ) external payable nonReentrant {
        uint256 deadline = block.timestamp + 300;

        IBaluniV1Pool baluniPool = IBaluniV1Pool(poolAddress);

        address[] memory poolAssets = baluniPool.getAssets();
        uint256[] memory amounts = new uint256[](poolAssets.length);

        if (tokenIn == address(0)) {
            require(msg.value == amountIn, 'Incorrect ETH amount');
            IWETH(WETH9).deposit{value: amountIn}();
            tokenIn = WETH9;
        } else {
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        }

        for (uint256 i = 0; i < poolAssets.length; i++) {
            if (tokenIn == poolAssets[i]) {
                amounts[i] = amountIn / poolAssets.length;
            } else {
                amounts[i] = _swap(tokenIn, poolAssets[i], amountIn / poolAssets.length, address(this));
                require(amounts[i] >= minAmountsOut, 'Insufficient output amount');
            }
        }

        for (uint256 i = 0; i < poolAssets.length; i++) {
            IERC20(poolAssets[i]).approve(address(baluniPool), amounts[i]);
        }

        baluniPool.deposit(receiver, amounts, deadline);
    }

    function zapOut(
        address poolAddress,
        uint256 share,
        address tokenOut,
        uint256 minAmountOut,
        address receiver
    ) external nonReentrant {
        uint256 deadline = block.timestamp + 300;

        IBaluniV1Pool baluniPool = IBaluniV1Pool(poolAddress);

        address[] memory poolAssets = baluniPool.getAssets();
        uint256[] memory amounts = new uint256[](poolAssets.length);

        uint256[] memory balances = new uint256[](poolAssets.length);
        for (uint256 i = 0; i < poolAssets.length; i++) {
            balances[i] = IERC20(poolAssets[i]).balanceOf(address(this));
        }

        // Retrieve balances before withdrawal
        uint256 balanceBefore = IERC20(tokenOut).balanceOf(address(this));

        IERC20(poolAddress).transferFrom(msg.sender, address(this), share);
        IERC20(poolAddress).approve(address(baluniPool), share);

        // Withdraw from the pool
        baluniPool.withdraw(share, address(this), deadline);

        uint256 totalAmountOut = 0;

        for (uint256 i = 0; i < poolAssets.length; i++) {
            if (poolAssets[i] == tokenOut) {
                amounts[i] = IERC20(poolAssets[i]).balanceOf(address(this)) - balances[i];
                totalAmountOut += amounts[i];
            } else {
                amounts[i] = IERC20(poolAssets[i]).balanceOf(address(this)) - balances[i];
                totalAmountOut += _swap(poolAssets[i], tokenOut, amounts[i], msg.sender);
            }
        }

        uint256 balanceAfter = IERC20(tokenOut).balanceOf(address(this));
        totalAmountOut = balanceAfter - balanceBefore;

        require(totalAmountOut >= minAmountOut, 'Insufficient output amount');

        if (tokenOut == WETH9) {
            IWETH(WETH9).withdraw(totalAmountOut);
            payable(receiver).transfer(totalAmountOut);
        } else {
            IERC20(tokenOut).transfer(receiver, totalAmountOut);
        }
    }

    function _swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address receiver
    ) internal returns (uint256 amountOut) {
        address WMATIC = registry.getWNATIVE();
        if (tokenIn == tokenOut) {
            return amountIn;
        }

        IERC20(tokenIn).approve(address(baluniSwapper), amountIn);

        try baluniSwapper.singleSwap(tokenIn, tokenOut, amountIn, receiver) returns (uint256 _amountOut) {
            amountOut = _amountOut;
        } catch {
            amountOut = baluniSwapper.multiHopSwap(tokenIn, WMATIC, tokenOut, amountIn, receiver);
        }
        require(amountOut > 0, 'Swap failed');
        return amountOut;
    }
}
