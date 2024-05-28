// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import './interfaces/IBaluniV1PoolFactory.sol';
import './interfaces/IBaluniV1Pool.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

/**
 * @title SmartRouterOrder
 * @dev This contract serves as a smart router for routing swap orders through multiple pools.
 */
contract SmartRouterOrder is Initializable, OwnableUpgradeable, UUPSUpgradeable {
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
   * @dev Reinitializes the contract with a new pool factory address.
   * @param _poolFactory The address of the new BaluniV1PoolFactory contract.
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
   * @dev Swaps tokens through the best pool based on token-specific liquidity and asset deviation.
   * @param fromToken The address of the token to swap from.
   * @param toToken The address of the token to swap to.
   * @param amount The amount of tokens to swap.
   * @param receiver The address that will receive the swapped tokens.
   * @return The amount of tokens received after the swap.
   */
  function smartSwap(address fromToken, address toToken, uint256 amount, address receiver) external returns (uint256) {
    require(amount > 0, 'Amount must be greater than zero');

    // Get all pools that contain fromToken
    address[] memory fromPools = poolFactory.getPoolsByAsset(fromToken);
    uint256 bestAmountOut = 0;
    address bestPoolAddress;
    uint256 bestTokenLiquidity = 0;

    // Iterate over all pools to find the best pool based on token-specific liquidity and asset deviation
    for (uint256 i = 0; i < fromPools.length; i++) {
      IBaluniV1Pool pool = IBaluniV1Pool(fromPools[i]);
      (bool[] memory directions, uint256[] memory deviations) = pool.getDeviation();
      (uint256 totalValuation, uint256[] memory valuations) = pool.computeTotalValuation();

      // Check if fromToken is overweight and get the liquidity of the specific token
      for (uint256 j = 0; j < directions.length; j++) {
        if (pool.assetInfos(j).asset == fromToken) {
          uint256 tokenLiquidity = valuations[j];
          if (directions[j] && tokenLiquidity > bestTokenLiquidity) {
            bestTokenLiquidity = tokenLiquidity;
            bestPoolAddress = fromPools[i];
          }
        }
      }
    }

    require(bestPoolAddress != address(0), 'No suitable pool found');

    // Perform the swap in the best pool
    IBaluniV1Pool bestPool = IBaluniV1Pool(bestPoolAddress);
    IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
    IERC20(fromToken).approve(bestPoolAddress, amount);
    uint256 amountReceived = bestPool.swap(fromToken, toToken, amount, receiver);

    return amountReceived;
  }

  /**
   * @dev Changes the address of the pool factory contract.
   * Can only be called by the contract owner.
   * @param _poolFactory The new address of the pool factory contract.
   */
  function changePoolFactory(address _poolFactory) external onlyOwner {
    poolFactory = IBaluniV1PoolFactory(_poolFactory);
  }
}
