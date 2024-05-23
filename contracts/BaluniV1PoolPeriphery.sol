// SPDX-License-Identifier: GNU AGPLv3

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

import './interfaces/IBaluniV1Pool.sol';
import './interfaces/IBaluniV1PoolFactory.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';

/**
 * @title BaluniV1Periphery
 * @dev This contract serves as the periphery contract for interacting with BaluniV1Pool contracts.
 * It provides functions for swapping tokens, adding liquidity, removing liquidity, and getting the amount out for a given swap.
 */
contract BaluniV1PoolPeriphery is Initializable, OwnableUpgradeable, UUPSUpgradeable {
  // A reference to the BaluniV1PoolFactory contract.
  IBaluniV1PoolFactory public poolFactory;

  /**
   * @dev Initializes the contract by setting the pool factory address.
   * @param _poolFactory The address of the BaluniV1PoolFactory contract.
   */
  function initialize(address _poolFactory) public initializer {
    __UUPSUpgradeable_init();
    __Ownable_init(msg.sender);
    poolFactory = IBaluniV1PoolFactory(_poolFactory);
  }

  /**
   * @dev Reinitializes the contract with the specified `_poolFactory` address and `version`.
   * @param _poolFactory The address of the BaluniV1PoolFactory contract.
   * @param version The version of the contract.
   */
  function reinitialize(address _poolFactory, uint64 version) public reinitializer(version) {
    __UUPSUpgradeable_init();
    __Ownable_init(msg.sender);
    poolFactory = IBaluniV1PoolFactory(_poolFactory);
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

    // Get all pools containing the toToken
    address[] memory poolsContainingToken = poolFactory.getPoolsByAsset(toToken);

    for (uint256 i = 0; i < poolsContainingToken.length; i++) {
      IBaluniV1Pool _pool = IBaluniV1Pool(poolsContainingToken[i]);
      (bool direction1, uint256 deviationAsset1, bool direction2, uint256 deviationAsset2) = _pool.getDeviation();

      // Check if toToken is in excess
      if (
        _pool.asset1() == toToken &&
        deviationAsset1 > _pool.weight1() &&
        direction1 &&
        IERC20(_pool.asset1()).balanceOf(address(_pool)) > amount
      ) {
        // Perform swap in this pool if toToken is in excess
        return _performSwapInPool(_pool, fromToken, toToken, amount);
      } else if (
        _pool.asset2() == toToken &&
        deviationAsset2 > _pool.weight2() &&
        direction2 &&
        IERC20(_pool.asset2()).balanceOf(address(_pool)) > amount
      ) {
        // Perform swap in this pool if toToken is in excess
        return _performSwapInPool(_pool, fromToken, toToken, amount);
      }
    }

    // Default swap in the main pool if no other pools have excess toToken
    address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
    IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
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
    IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
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

    IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
    pool.transferFrom(msg.sender, address(this), share);
    pool.approve(poolAddress, share);

    pool.exit(share);

    IERC20(pool.asset1()).transfer(msg.sender, IERC20(pool.asset1()).balanceOf(address(this)));
    IERC20(pool.asset2()).transfer(msg.sender, IERC20(pool.asset2()).balanceOf(address(this)));
  }

  /**
   * @dev Gets the amount of tokens received after a swap in a BaluniV1Pool.
   * @param fromToken The address of the token to swap from.
   * @param toToken The address of the token to swap to.
   * @param amount The amount of tokens to swap.
   * @return The amount of tokens received after the swap.
   */
  function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256) {
    address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
    IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
    return pool.getAmountOut(fromToken, toToken, amount);
  }

  /**
   * @dev Performs rebalance if needed for the given tokens.
   * @param fromToken The address of the token to rebalance from.
   * @param toToken The address of the token to rebalance to.
   */
  function perfromRebalanceIfNeeded(address fromToken, address toToken) external {
    address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
    IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
    pool.performRebalanceIfNeeded(msg.sender);
  }

  /**
   * @dev Returns an array of pool addresses that contain the given token.
   * @param token The address of the token to search for.
   * @return An array of pool addresses.
   */
  function getPoolsContainingToken(address token) external view returns (address[] memory) {
    return poolFactory.getPoolsByAsset(token);
  }

  /**
   * @dev Performs a swap in the BaluniV1Pool.
   * @param pool The BaluniV1Pool contract address.
   * @param fromToken The address of the token to swap from.
   * @param toToken The address of the token to swap to.
   * @param amount The amount of tokens to swap.
   * @return The amount of tokens received after the swap.
   */
  function _performSwapInPool(
    IBaluniV1Pool pool,
    address fromToken,
    address toToken,
    uint256 amount
  ) internal returns (uint256) {
    // Transfer tokens from the sender to this contract
    IERC20(fromToken).transferFrom(msg.sender, address(this), amount);

    // Approve the pool to spend the transferred tokens
    IERC20(fromToken).approve(address(pool), amount);

    // Perform the swap in the pool
    uint256 amountOut = pool.swap(fromToken, toToken, amount);

    // Transfer the swapped tokens back to the sender
    IERC20(toToken).transfer(msg.sender, amountOut);

    return amountOut;
  }
}
