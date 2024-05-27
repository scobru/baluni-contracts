// SPDX-License-Identifier: GNU AGPLv3

pragma solidity 0.8.25;

import './interfaces/IBaluniV1PoolFactory.sol';
import './interfaces/IBaluniV1Pool.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

/**
 * @title BaluniV1PoolPeriphery
 * @dev This contract serves as the periphery contract for interacting with BaluniV1Pool contracts.
 * It provides functions for swapping tokens, adding liquidity, removing liquidity, and getting the amount out for a given swap.
 */
contract BaluniV1PoolPeriphery is Initializable, OwnableUpgradeable, UUPSUpgradeable {
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
   * @dev Initializes the contract by setting the pool factory address.
   * @param _poolFactory The address of the BaluniV1PoolFactory contract.
   */
  function reinitialize(address _poolFactory, uint64 version) public reinitializer(version) {
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

    // Get the pool address for the given tokens
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
   * @param amounts An array of amounts for each asset to add as liquidity.
   */
  function addLiquidity(uint256[] calldata amounts, address poolAddress) external {
    IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
    address[] memory assets = pool.getAssets(); // Get the assets in the pool

    for (uint256 i = 0; i < assets.length; i++) {
      address asset = assets[i];
      uint256 amount = amounts[i];
      IERC20(asset).transferFrom(msg.sender, poolAddress, amount);
    }

    pool.mint(msg.sender);
  }

  /**
   * @dev Removes liquidity from a BaluniV1Pool.
   * @param share The amount of liquidity tokens to remove.
   * @param poolAddress The address of the BaluniV1Pool.
   */
  function removeLiquidity(uint256 share, address poolAddress) external {
    require(share > 0, 'Share must be greater than zero');
    IERC20 poolToken = IERC20(poolAddress);

    // Check allowance
    uint256 allowance = poolToken.allowance(msg.sender, address(this));
    require(allowance >= share, 'Insufficient allowance');

    // Check balance
    uint256 balance = poolToken.balanceOf(msg.sender);
    require(balance >= share, 'Insufficient balance');

    bool success = poolToken.transferFrom(msg.sender, poolAddress, share);
    require(success, 'Transfer failed');

    IBaluniV1Pool(poolAddress).burn(msg.sender);
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
   * @param poolAddress The address of the token pool to rebalance.
   */
  function performRebalanceIfNeeded(address poolAddress) external {
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
   * @dev Returns the version of the contract.
   * @return The version string.
   */
  function getVersion() external view returns (uint64) {
    return _getInitializedVersion();
  }

  function changePoolFactory(address _poolFactory) external onlyOwner {
    poolFactory = IBaluniV1PoolFactory(_poolFactory);
  }
}
