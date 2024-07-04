// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

import '../interfaces/IBaluniV1Registry.sol';
import '../interfaces/IBaluniV1Swapper.sol';
import '../interfaces/IBaluniV1HyperUniProxy.sol';
import '../interfaces/IBaluniV1Hypervisor.sol';

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

contract BaluniV1HyperPoolZap is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable {
    IBaluniV1Registry public registry;
    IBaluniV1Swapper public baluniSwapper;
    IBaluniV1HyperUniProxy public baluniHyperUniProxy;
    address public WETH9;

    function initialize(address _registry, address _uniProxy) public initializer {
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        registry = IBaluniV1Registry(_registry);
        baluniSwapper = IBaluniV1Swapper(registry.getBaluniSwapper());
        baluniHyperUniProxy = IBaluniV1HyperUniProxy(_uniProxy);
        WETH9 = registry.getWNATIVE();
    }

    function changeUniProxy(address _uniProxy) external onlyOwner {
        baluniHyperUniProxy = IBaluniV1HyperUniProxy(_uniProxy);
    }

    function changeSwapper(address _swapper) external onlyOwner {
        baluniSwapper = IBaluniV1Swapper(_swapper);
    }

    function changeRegistry(address _registry) external onlyOwner {
        registry = IBaluniV1Registry(_registry);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    receive() external payable {}

    function zapIn(
        address hypervisor,
        address tokenIn,
        uint256 amountIn,
        uint256 minAmountsOut,
        address receiver
    ) external payable nonReentrant {
        IBaluniV1Hypervisor hyperPool = IBaluniV1Hypervisor(hypervisor);

        address token0 = hyperPool.token0();
        address token1 = hyperPool.token1();

        address[] memory poolAssets = new address[](2);
        poolAssets[0] = token0;
        poolAssets[1] = token1;

        uint256[] memory amounts = new uint256[](2);

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
            IERC20(poolAssets[i]).approve(address(hypervisor), amounts[i]);
        }

        baluniHyperUniProxy.deposit(amounts[0], amounts[1], receiver, address(this), hypervisor);
    }

    function zapOut(
        address hypervisor,
        uint256 share,
        address tokenOut,
        uint256 minAmountOut,
        address receiver
    ) external nonReentrant {
        IBaluniV1Hypervisor hyperPool = IBaluniV1Hypervisor(hypervisor);

        address token0 = hyperPool.token0();
        address token1 = hyperPool.token1();

        address[] memory poolAssets = new address[](2);
        poolAssets[0] = token0;
        poolAssets[1] = token1;

        uint256[] memory amounts = new uint256[](2);

        uint256[] memory balances = new uint256[](poolAssets.length);
        for (uint256 i = 0; i < poolAssets.length; i++) {
            balances[i] = IERC20(poolAssets[i]).balanceOf(address(this));
        }

        // Retrieve balances before withdrawal
        uint256 balanceBefore = IERC20(tokenOut).balanceOf(address(this));

        IERC20(hypervisor).transferFrom(msg.sender, address(this), share);
        IERC20(hypervisor).approve(address(hypervisor), share);

        uint256[4] memory minAmounts;

        minAmounts[0] = 0;
        minAmounts[1] = 0;
        minAmounts[2] = 0;
        minAmounts[3] = 0;

        // Withdraw from the pool
        hyperPool.withdraw(share, msg.sender, address(this), minAmounts);

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
