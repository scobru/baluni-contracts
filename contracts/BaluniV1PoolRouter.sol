// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import './BaluniV1Pool.sol';
import './BaluniV1PoolFactory.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

contract BaluniV1Periphery is OwnableUpgradeable {
  using SafeERC20Upgradeable for IERC20Upgradeable;

  BaluniV1PoolFactory public poolFactory;

  function initialize(address _poolFactory) public initializer {
    __Ownable_init();
    poolFactory = BaluniV1PoolFactory(_poolFactory);
  }

  function swap(address poolAddress, address fromToken, address toToken, uint256 amount) external returns (uint256) {
    require(amount > 0, 'Amount must be greater than zero');

    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    IERC20Upgradeable(fromToken).safeTransferFrom(msg.sender, address(this), amount);
    IERC20Upgradeable(fromToken).approve(poolAddress, amount);

    uint256 amountOut = pool.swap(fromToken, toToken, amount);
    IERC20Upgradeable(toToken).safeTransfer(msg.sender, amountOut);

    return amountOut;
  }

  function addLiquidity(address poolAddress, uint256 amount1, uint256 amount2) external returns (uint256) {
    require(amount1 > 0 || amount2 > 0, 'Amounts must be greater than zero');

    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    IERC20Upgradeable(pool.asset1()).safeTransferFrom(msg.sender, address(this), amount1);
    IERC20Upgradeable(pool.asset2()).safeTransferFrom(msg.sender, address(this), amount2);

    IERC20Upgradeable(pool.asset1()).approve(poolAddress, amount1);
    IERC20Upgradeable(pool.asset2()).approve(poolAddress, amount2);

    uint256 liquidity = pool.addLiquidity(amount1, amount2);
    pool.transfer(msg.sender, liquidity);

    return liquidity;
  }

  function removeLiquidity(address poolAddress, uint256 share) external {
    require(share > 0, 'Share must be greater than zero');

    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    pool.transferFrom(msg.sender, address(this), share);
    pool.approve(poolAddress, share);

    pool.exit(share);

    IERC20Upgradeable(pool.asset1()).safeTransfer(
      msg.sender,
      IERC20Upgradeable(pool.asset1()).balanceOf(address(this))
    );
    IERC20Upgradeable(pool.asset2()).safeTransfer(
      msg.sender,
      IERC20Upgradeable(pool.asset2()).balanceOf(address(this))
    );
  }

  function getAmountOut(
    address poolAddress,
    address fromToken,
    address toToken,
    uint256 amount
  ) external view returns (uint256) {
    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    return pool.getAmountOut(fromToken, toToken, amount);
  }
}
