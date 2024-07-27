// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

import '../interfaces/IBaluniV1Registry.sol';
import '../interfaces/IBaluniV1Swapper.sol';
import '../interfaces/IBaluniV1HyperUniProxy.sol';

interface IClearingV2 {
    function getDepositAmount(
        address pos,
        address token,
        uint256 _deposit
    ) external view returns (uint256 amountStart, uint256 amountEnd);

    function applyRatio(
        address pos,
        address token,
        uint256 total0,
        uint256 total1
    ) external view returns (uint256 ratioStart, uint256 ratioEnd);
}

interface IBaluniV1Hypervisor {
    function deposit(uint256, uint256, address, address, uint256[4] memory minIn) external returns (uint256);

    function withdraw(uint256, address, address, uint256[4] memory) external returns (uint256, uint256);

    function compound()
        external
        returns (uint128 baseToken0Owed, uint128 baseToken1Owed, uint128 limitToken0Owed, uint128 limitToken1Owed);

    function compound(
        uint256[4] memory inMin
    )
        external
        returns (uint128 baseToken0Owed, uint128 baseToken1Owed, uint128 limitToken0Owed, uint128 limitToken1Owed);

    function rebalance(
        int24 _baseLower,
        int24 _baseUpper,
        int24 _limitLower,
        int24 _limitUpper,
        address _feeRecipient,
        uint256[4] memory minIn,
        uint256[4] memory outMin
    ) external;

    function addBaseLiquidity(uint256 amount0, uint256 amount1, uint256[2] memory minIn) external;

    function addLimitLiquidity(uint256 amount0, uint256 amount1, uint256[2] memory minIn) external;

    function pullLiquidity(
        int24 tickLower,
        int24 tickUpper,
        uint128 shares,
        uint256[2] memory amountMin
    ) external returns (uint256 base0, uint256 base1);

    function pullLiquidity(
        uint256 shares,
        uint256[4] memory minAmounts
    ) external returns (uint256 base0, uint256 base1, uint256 limit0, uint256 limit1);

    function addLiquidity(
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1,
        uint256[2] memory inMin
    ) external;

    function pool() external view returns (IUniswapV3Pool);

    function currentTick() external view returns (int24 tick);

    function tickSpacing() external view returns (int24 spacing);

    function baseLower() external view returns (int24 tick);

    function baseUpper() external view returns (int24 tick);

    function limitLower() external view returns (int24 tick);

    function limitUpper() external view returns (int24 tick);

    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function deposit0Max() external view returns (uint256);

    function deposit1Max() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function getTotalAmounts() external view returns (uint256 total0, uint256 total1);

    function getBasePosition() external view returns (uint256 liquidity, uint256 total0, uint256 total1);

    function totalSupply() external view returns (uint256);

    function setWhitelist(address _address) external;

    function setFee(uint8 newFee) external;

    function removeWhitelisted() external;

    function transferOwnership(address newOwner) external;

    function toggleDirectDeposit() external;
}

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
        // IBaluniV1Hypervisor hyperPool = IBaluniV1Hypervisor(hypervisor);
        // address token0 = address(hyperPool.token0());
        // address token1 = address(hyperPool.token1());
        // address[] memory poolAssets = new address[](2);
        // poolAssets[0] = token0;
        // poolAssets[1] = token1;
        // uint256[] memory amounts = new uint256[](2);
        // if (tokenIn == address(0)) {
        //     require(msg.value == amountIn, 'Incorrect ETH amount');
        //     IWETH(WETH9).deposit{value: amountIn}();
        //     tokenIn = WETH9;
        // } else {
        //     IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        // }
        // // Ottieni i rapporti di deposito utilizzando il contratto ClearingV2
        // IClearingV2 clearingV2 = IClearingV2(baluniHyperUniProxy.clearance());
        // (uint256 amount1Min, uint256 amount1Max) = clearingV2.getDepositAmount(hypervisor, token0, amountIn);
        // (uint256 amount0Min, uint256 amount0Max) = clearingV2.getDepositAmount(hypervisor, token1, amountIn);
        // // Calcola gli importi effettivi da depositare
        // uint256 amount0 = amount0Min;
        // uint256 amount1 = (amount1Min + amount1Max) / 2;
        // // Verifica che gli importi siano sufficienti per il deposito
        // require(amount0 > 0 && amount1 > 0, 'Calculated amounts are insufficient');
        // // Swap per ottenere i token necessari
        // for (uint256 i = 0; i < poolAssets.length; i++) {
        //     if (tokenIn == poolAssets[i]) {
        //         amounts[i] = (amountIn * (i == 0 ? amount0 : amount1)) / (amount0 + amount1);
        //     } else {
        //         amounts[i] = _swap(
        //             tokenIn,
        //             poolAssets[i],
        //             (amountIn * (i == 0 ? amount0 : amount1)) / (amount0 + amount1),
        //             address(this)
        //         );
        //         require(amounts[i] >= minAmountsOut, 'Insufficient output amount');
        //     }
        // }
        // for (uint256 i = 0; i < poolAssets.length; i++) {
        //     IERC20(poolAssets[i]).approve(address(baluniHyperUniProxy), amounts[i]);
        //     IERC20(poolAssets[i]).approve(address(hypervisor), amounts[i]);
        // }
        // require(amounts[0] > 0 && amounts[1] > 0, 'Insufficient amounts');
        // // Verifica dei bilanci dei token
        // require(IERC20(token0).balanceOf(address(this)) >= amounts[0], 'Insufficient token0 balance');
        // require(IERC20(token1).balanceOf(address(this)) >= amounts[1], 'Insufficient token1 balance');
        // // Deposita i token nel proxy
        // baluniHyperUniProxy.deposit(amounts[0], amounts[1], receiver, address(this), hypervisor);
    }

    function zapOut(
        address hypervisor,
        uint256 share,
        address tokenOut,
        uint256 minAmountOut,
        address receiver
    ) external nonReentrant {
        IBaluniV1Hypervisor hyperPool = IBaluniV1Hypervisor(hypervisor);

        address token0 = address(hyperPool.token0());
        address token1 = address(hyperPool.token1());

        address[] memory poolAssets = new address[](2);
        poolAssets[0] = token0;
        poolAssets[1] = token1;

        uint256[] memory amounts = new uint256[](2);

        uint256[] memory balances = new uint256[](poolAssets.length);
        for (uint256 i = 0; i < poolAssets.length; i++) {
            balances[i] = IERC20(poolAssets[i]).balanceOf(address(this));
        }

        uint256 balanceBefore = IERC20(tokenOut).balanceOf(address(this));

        IERC20(hypervisor).transferFrom(msg.sender, address(this), share);
        IERC20(hypervisor).approve(address(hypervisor), share);

        uint256[4] memory minAmounts;

        minAmounts[0] = 0;
        minAmounts[1] = 0;
        minAmounts[2] = 0;
        minAmounts[3] = 0;

        // Withdraw from the pool
        hyperPool.withdraw(share, address(this), address(this), minAmounts);

        uint256 totalAmountOut = 0;

        for (uint256 i = 0; i < poolAssets.length; i++) {
            if (poolAssets[i] == tokenOut) {
                amounts[i] = IERC20(poolAssets[i]).balanceOf(address(this)) - balances[i];
                totalAmountOut += amounts[i];
            } else {
                amounts[i] = IERC20(poolAssets[i]).balanceOf(address(this)) - balances[i];
                totalAmountOut += _swap(poolAssets[i], tokenOut, amounts[i], address(this));
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
