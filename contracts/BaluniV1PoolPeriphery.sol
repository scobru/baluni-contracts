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
  function swap(address fromToken, address toToken, uint256 amount, address receiver) external returns (uint256) {
    require(amount > 0, 'Amount must be greater than zero');

    // Get the pool address for the given tokens
    address poolAddress = poolFactory.getPoolByAssets(fromToken, toToken);
    IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);

    IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
    IERC20(fromToken).approve(poolAddress, amount);

    uint256 amountOut = pool.swap(fromToken, toToken, amount, receiver);

    return amountOut;
  }

  /**
   * @dev Performs batch swaps between multiple token pairs.
   * @param fromTokens An array of addresses representing the tokens to swap from.
   * @param toTokens An array of addresses representing the tokens to swap to.
   * @param amounts An array of amounts representing the amounts to swap.
   * @param receivers An array of addresses representing the receivers of the swapped tokens.
   * @return An array of amounts representing the amounts of tokens received after the swaps.
   */
  function batchSwap(
    address[] calldata fromTokens,
    address[] calldata toTokens,
    uint256[] calldata amounts,
    address[] calldata receivers
  ) external returns (uint256[] memory) {
    require(
      fromTokens.length == toTokens.length && toTokens.length == amounts.length && amounts.length == receivers.length,
      'Input arrays length mismatch'
    );

    uint256[] memory amountsOut = new uint256[](fromTokens.length);

    for (uint256 i = 0; i < fromTokens.length; i++) {
      require(amounts[i] > 0, 'Amount must be greater than zero');

      // Transfer fromToken from sender to this contract
      IERC20(fromTokens[i]).transferFrom(msg.sender, address(this), amounts[i]);

      // Get the pool address for the given tokens
      address poolAddress = poolFactory.getPoolByAssets(fromTokens[i], toTokens[i]);
      IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);

      // Approve the pool to spend fromToken
      IERC20(fromTokens[i]).approve(poolAddress, amounts[i]);

      // Perform the swap
      uint256 amountOut = pool.swap(fromTokens[i], toTokens[i], amounts[i], receivers[i]);
      amountsOut[i] = amountOut;
    }

    return amountsOut;
  }

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
   * @dev Adds liquidity to a BaluniV1Pool.
   * @param amounts An array of amounts for each asset to add as liquidity.
   */
  function addLiquidity(uint256[] calldata amounts, address poolAddress, address receiver) external {
    IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
    address[] memory assets = pool.getAssets(); // Get the assets in the pool

    for (uint256 i = 0; i < assets.length; i++) {
      address asset = assets[i];
      uint256 amount = amounts[i];
      IERC20(asset).transferFrom(msg.sender, poolAddress, amount);
    }

    pool.mint(receiver);
  }

  function addLiquidityOneSide(uint256 amount, address token, address poolAddress, address receiver) external {
    IBaluniV1Pool pool = IBaluniV1Pool(poolAddress);
    address[] memory assets = pool.getAssets(); // Get the assets in the pool

    uint256 index = 0;
    for (uint256 i = 0; i < assets.length; i++) {
      if (assets[i] == token) {
        index = i;
        break;
      }
    }

    IERC20(token).transferFrom(msg.sender, poolAddress, amount);
    pool.mintOneSide(index, amount, receiver);
  }

  /**
   * @dev Removes liquidity from a BaluniV1Pool.
   * @param share The amount of liquidity tokens to remove.
   * @param poolAddress The address of the BaluniV1Pool.
   */
  function removeLiquidity(uint256 share, address poolAddress, address receiver) external {
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

    IBaluniV1Pool(poolAddress).burn(receiver);
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

  /**
   * @dev Changes the address of the pool factory contract.
   * Can only be called by the contract owner.
   * @param _poolFactory The new address of the pool factory contract.
   */
  function changePoolFactory(address _poolFactory) external onlyOwner {
    poolFactory = IBaluniV1PoolFactory(_poolFactory);
  }
}
