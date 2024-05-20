// SPDX-License-Identifier: GNU AGPLv3

/**
 * @title BaluniV1Periphery
 * @dev This contract serves as the periphery contract for interacting with BaluniV1Pool contracts.
 * It provides functions for swapping tokens, adding liquidity, removing liquidity, and getting the amount out for a given swap.
 */
pragma solidity 0.8.25;

import './BaluniV1Pool.sol';
import './BaluniV1PoolFactory.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

abstract contract BaluniV1Periphery is Initializable, OwnableUpgradeable, UUPSUpgradeable {
  using SafeERC20Upgradeable for IERC20Upgradeable;

  // A reference to the BaluniV1PoolFactory contract.
  BaluniV1PoolFactory public poolFactory;

  /**
   * @dev Initializes the contract by setting the pool factory address.
   * @param _poolFactory The address of the BaluniV1PoolFactory contract.
   */
  function initialize(address _poolFactory) public initializer {
    __UUPSUpgradeable_init();
    __Ownable_init();
    poolFactory = BaluniV1PoolFactory(_poolFactory);
  }

  /**
   * @dev Swaps tokens in a BaluniV1Pool.
   * @param poolAddress The address of the BaluniV1Pool contract.
   * @param fromToken The address of the token to swap from.
   * @param toToken The address of the token to swap to.
   * @param amount The amount of tokens to swap.
   * @return The amount of tokens received after the swap.
   */
  function swap(address poolAddress, address fromToken, address toToken, uint256 amount) external returns (uint256) {
    require(amount > 0, 'Amount must be greater than zero');

    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    IERC20Upgradeable(fromToken).safeTransferFrom(msg.sender, address(this), amount);
    IERC20Upgradeable(fromToken).approve(poolAddress, amount);

    uint256 amountOut = pool.swap(fromToken, toToken, amount);
    IERC20Upgradeable(toToken).safeTransfer(msg.sender, amountOut);

    return amountOut;
  }

  /**
   * @dev Adds liquidity to a BaluniV1Pool.
   * @param poolAddress The address of the BaluniV1Pool contract.
   * @param amount1 The amount of the first asset to add.
   * @param amount2 The amount of the second asset to add.
   * @return The amount of liquidity tokens received after adding liquidity.
   */
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

  /**
   * @dev Removes liquidity from a BaluniV1Pool.
   * @param poolAddress The address of the BaluniV1Pool contract.
   * @param share The amount of liquidity tokens to remove.
   */
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

  /**
   * @dev Gets the amount of tokens received after a swap in a BaluniV1Pool.
   * @param poolAddress The address of the BaluniV1Pool contract.
   * @param fromToken The address of the token to swap from.
   * @param toToken The address of the token to swap to.
   * @param amount The amount of tokens to swap.
   * @return The amount of tokens received after the swap.
   */
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
