// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import './BaluniV1Pool.sol';
import './BaluniV1PoolFactory.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

/**
 * @title BaluniV1Periphery
 * @dev This contract serves as the periphery contract for interacting with BaluniV1Pool contracts.
 * It provides functions for swapping tokens, adding liquidity, removing liquidity, and getting the amount out for a given swap.
 */
contract BaluniV1PoolPeriphery is Initializable, OwnableUpgradeable, UUPSUpgradeable {
  // A reference to the BaluniV1PoolFactory contract.
  BaluniV1PoolFactory public poolFactory;

  /**
   * @dev Initializes the contract by setting the pool factory address.
   * @param _poolFactory The address of the BaluniV1PoolFactory contract.
   */
  function initialize(address _poolFactory) public initializer {
    __UUPSUpgradeable_init();
    __Ownable_init(msg.sender);
    poolFactory = BaluniV1PoolFactory(_poolFactory);
  }

  /**
   * @dev Reinitializes the contract with the specified `_poolFactory` address and `version`.
   * @param _poolFactory The address of the BaluniV1PoolFactory contract.
   * @param version The version of the contract.
   */
  function reinitialize(address _poolFactory, uint64 version) public reinitializer(version) {
    __UUPSUpgradeable_init();
    __Ownable_init(msg.sender);
    poolFactory = BaluniV1PoolFactory(_poolFactory);
  }

  /**
   * @dev Internal function to authorize an upgrade to a new implementation contract.
   * @param newImplementation The address of the new implementation contract.
   * @notice This function can only be called by the contract owner.
   */
  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  /**
   * @dev Swaps tokens in a BaluniV1Pool.
   * @param fromToken The address of the token to swap from.
   * @param toToken The address of the token to swap to.
   * @param amount The amount of tokens to swap.
   * @return The amount of tokens received after the swap.
   */
  function swap(address fromToken, address toToken, uint256 amount) external returns (uint256) {
    require(amount > 0, 'Amount must be greater than zero');
    address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
    IERC20(fromToken).approve(poolAddress, amount);

    uint256 amountOut = pool.swap(fromToken, toToken, amount);
    IERC20(toToken).transfer(msg.sender, amountOut);

    return amountOut;
  }

  /**
   * @dev Adds liquidity to a BaluniV1Pool.
   * @param amount1 The amount of the first asset to add.
   * @param amount2 The amount of the second asset to add.
   * @return The amount of liquidity tokens received after adding liquidity.
   */
  function addLiquidity(
    uint256 amount1,
    address fromToken,
    uint256 amount2,
    address toToken
  ) external returns (uint256) {
    require(amount1 > 0 || amount2 > 0, 'Amounts must be greater than zero');
    address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    IERC20(pool.asset1()).transferFrom(msg.sender, address(this), amount1);
    IERC20(pool.asset2()).transferFrom(msg.sender, address(this), amount2);

    IERC20(pool.asset1()).approve(poolAddress, amount1);
    IERC20(pool.asset2()).approve(poolAddress, amount2);

    uint256 liquidity = pool.addLiquidity(amount1, amount2);
    pool.transfer(msg.sender, liquidity);

    return liquidity;
  }

  /**
   * @dev Removes liquidity from a BaluniV1Pool.
   * @param share The amount of liquidity tokens to remove.
   */
  function removeLiquidity(address fromToken, address toToken, uint256 share) external {
    require(share > 0, 'Share must be greater than zero');
    address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);

    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    pool.transferFrom(msg.sender, address(this), share);
    pool.approve(poolAddress, share);

    pool.exit(share);

    IERC20(pool.asset1()).transfer(msg.sender, IERC20(pool.asset1()).balanceOf(address(this)));
    IERC20(pool.asset2()).transfer(msg.sender, IERC20(pool.asset2()).balanceOf(address(this)));
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

  function perfromRebalanceIfNeeded(address fromToken, address toToken) external {
    address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
    BaluniV1Pool pool = BaluniV1Pool(poolAddress);
    pool.performRebalanceIfNeeded();
  }
}
