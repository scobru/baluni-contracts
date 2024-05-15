// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import './interfaces/IBaluniV1Rebalancer.sol';
import './interfaces/IOracle.sol';

import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

contract BaluniV1Pool is OwnableUpgradeable, ERC20Upgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable {
  using SafeERC20Upgradeable for IERC20Upgradeable;

  IBaluniV1Rebalancer public rebalancer;
  IERC20Upgradeable public asset1;
  IERC20Upgradeable public asset2;
  IOracle public oracle;
  uint256 public constant SWAP_FEE_BPS = 30;

  function _authorizeUpgrade(address) internal override onlyOwner {}

  /**
   * @dev Initializes the BaluniV1Pool contract.
   * @param _oracle The address of the oracle contract.
   * @param _rebalancer The address of the rebalancer contract.
   * @param _asset1 The address of the first asset contract.
   * @param _asset2 The address of the second asset contract.
   */
  function initialize(address _oracle, address _rebalancer, address _asset1, address _asset2) public initializer {
    __Ownable_init();
    __ERC20_init('Baluni LP', 'BALUNI-LP');
    __ReentrancyGuard_init();
    __UUPSUpgradeable_init();

    rebalancer = IBaluniV1Rebalancer(_rebalancer);
    asset1 = IERC20Upgradeable(_asset1);
    asset2 = IERC20Upgradeable(_asset2);
    oracle = IOracle(_oracle);
    asset1.approve(address(rebalancer), type(uint256).max);
    asset2.approve(address(rebalancer), type(uint256).max);
  }

  /**
   * @dev Calculates the received amount after applying a fee, based on the conversion rate between two tokens.
   * @param fromToken The address of the token being converted from.
   * @param toToken The address of the token being converted to.
   * @param amountAfterFee The amount to be converted after applying a fee.
   * @return The received amount after applying the conversion rate and fee.
   */
  function _calculateReceivedAmount(
    address fromToken,
    address toToken,
    uint256 amountAfterFee
  ) internal view returns (uint256) {
    uint256 rate = oracle.getRate(IERC20Upgradeable(fromToken), IERC20Upgradeable(toToken), false);
    uint8 fromDecimals = IERC20MetadataUpgradeable(fromToken).decimals();
    uint8 toDecimals = IERC20MetadataUpgradeable(toToken).decimals();
    require(fromDecimals <= 18, 'FromToken has more than 18 decimals');
    require(toDecimals <= 18, 'ToToken has more than 18 decimals');

    uint256 receivedAmount;

    if (fromDecimals > toDecimals) {
      receivedAmount =
        ((amountAfterFee * rate * (10 ** (fromDecimals - toDecimals))) / 1e18) *
        (10 ** 18 - fromDecimals);
    } else if (toDecimals > fromDecimals) {
      receivedAmount =
        ((amountAfterFee * rate) / (10 ** (toDecimals - fromDecimals)) / 1e18) *
        (10 ** 18 - fromDecimals);
    } else {
      receivedAmount = (amountAfterFee * rate) / 1e18;
    }

    return receivedAmount;
  }

  /**
   * @dev Swaps tokens from one address to another.
   * @param fromToken The address of the token to swap from.
   * @param toToken The address of the token to swap to.
   * @param amount The amount of tokens to swap.
   * @return The amount of tokens received after the swap.
   */
  function swap(address fromToken, address toToken, uint256 amount) external nonReentrant returns (uint256) {
    // Function implementation...
  }

  function swap(address fromToken, address toToken, uint256 amount) external nonReentrant returns (uint256) {
    require(
      (fromToken == address(asset1) || fromToken == address(asset2)) &&
        (toToken == address(asset1) || toToken == address(asset2)),
      'Unsupported token'
    );
    require(fromToken != toToken, 'Cannot swap the same token');
    require(amount > 0, 'Amount must be greater than zero');

    IERC20Upgradeable(fromToken).safeTransferFrom(msg.sender, address(this), amount);

    uint256 fee = (amount * SWAP_FEE_BPS) / 10000;
    uint256 amountAfterFee = amount - fee;
    uint256 receivedAmount = _calculateReceivedAmount(fromToken, toToken, amountAfterFee);
    require(IERC20Upgradeable(toToken).balanceOf(address(this)) >= receivedAmount, 'Insufficient balance');

    IERC20Upgradeable(toToken).safeTransfer(msg.sender, receivedAmount);
    emit Swap(msg.sender, fromToken, toToken, amount, receivedAmount);

    performRebalanceIfNeeded();
    return receivedAmount;
  }

  /**
   * @dev Calculates the amount of `toToken` that will be received after swapping `fromToken` for `toToken`.
   * @param fromToken The address of the token being swapped from.
   * @param toToken The address of the token being swapped to.
   * @param amount The amount of `fromToken` being swapped.
   * @return The amount of `toToken` that will be received after the swap.
   * @notice This function is view-only and does not modify the contract state.
   * @notice The `fromToken` and `toToken` must be either `asset1` or `asset2`.
   * @notice The `fromToken` and `toToken` cannot be the same token.
   * @notice The `amount` must be greater than zero.
   * @notice The returned amount does not include any swap fees.
   */
  function getAmountOut(address fromToken, address toToken, uint256 amount) external view returns (uint256) {
    require(
      (fromToken == address(asset1) || fromToken == address(asset2)) &&
        (toToken == address(asset1) || toToken == address(asset2)),
      'Unsupported token'
    );
    require(fromToken != toToken, 'Cannot swap the same token');
    require(amount > 0, 'Amount must be greater than zero');

    uint256 fee = (amount * SWAP_FEE_BPS) / 10000;
    uint256 amountAfterFee = amount - fee;

    return _calculateReceivedAmount(fromToken, toToken, amountAfterFee);
  }

  /**
   * @dev Adds liquidity to the pool by transferring `amount1` of `asset1` and `amount2` of `asset2` from the caller's address to the contract.
   * The function calculates the received amount of `asset2` based on the amount of `asset1` added, and then calculates the total value in `asset2`.
   * If the total supply of the pool is 0, the function mints new tokens to the caller based on the total value in `asset2`.
   * If the total supply is not 0, the function calculates the total liquidity in `asset2` and mints new tokens to the caller proportionally.
   * Emits a `LiquidityAdded` event with the caller's address, `amount1`, `amount2`, and the amount of tokens minted (`toMint`).
   * @param amount1 The amount of `asset1` to be added as liquidity.
   * @param amount2 The amount of `asset2` to be added as liquidity.
   * @return The amount of tokens (`toMint`) minted and transferred to the caller.
   */
  function addLiquidity(uint256 amount1, uint256 amount2) external nonReentrant returns (uint256) {
    asset1.safeTransferFrom(msg.sender, address(this), amount1);
    asset2.safeTransferFrom(msg.sender, address(this), amount2);

    uint256 amount1InAsset2 = _calculateReceivedAmount(address(asset1), address(asset2), amount1);
    uint256 totalValueInAsset2 = amount1InAsset2 + amount2;

    uint256 totalSupply = totalSupply();
    uint256 toMint;

    if (totalSupply == 0) {
      toMint = (totalValueInAsset2 * 1e18) / 10 ** IERC20MetadataUpgradeable(address(asset2)).decimals();
    } else {
      uint256 totalLiquidity = totalLiquidityInAsset2();
      toMint = (totalValueInAsset2 * totalSupply) / totalLiquidity;
    }

    _mint(msg.sender, toMint);
    emit LiquidityAdded(msg.sender, amount1, amount2, toMint);
    return toMint;
  }

  /**
   * @dev Allows a user to exit the pool by redeeming their share of assets.
   * @param share The amount of shares to redeem.
   * Requirements:
   * - The caller must have a balance of shares greater than or equal to the specified amount.
   * - The pool must have sufficient assets to cover the redeemed shares.
   * Effects:
   * - Decreases the caller's share balance by the specified amount.
   * - Transfers the proportional amount of asset1 and asset2 to the caller.
   * Emits:
   * - LiquidityRemoved event with the caller's address, redeemed asset1 amount, redeemed asset2 amount, and the redeemed share amount.
   */
  function exit(uint256 share) external nonReentrant {
    require(balanceOf(msg.sender) >= share, 'Insufficient share');

    uint256 totalSupply = totalSupply();
    uint256 asset1Balance = asset1.balanceOf(address(this));
    uint256 asset2Balance = asset2.balanceOf(address(this));

    uint256 asset1Share = (asset1Balance * share) / totalSupply;
    uint256 asset2Share = (asset2Balance * share) / totalSupply;

    _burn(msg.sender, share);
    asset1.safeTransfer(msg.sender, asset1Share);
    asset2.safeTransfer(msg.sender, asset2Share);

    emit LiquidityRemoved(msg.sender, asset1Share, asset2Share, share);
  }

  /**
   * @dev Returns the total liquidity in asset1.
   * It calculates the total balance of asset1 held by the contract,
   * and also calculates the value of asset2 in terms of asset1.
   * The total liquidity is the sum of the asset1 balance and the value of asset2 in asset1.
   * @return The total liquidity in asset1.
   */
  function totalLiquidityInAsset1() public view returns (uint256) {
    // ...
  }

  function totalLiquidityInAsset1() public view returns (uint256) {
    uint256 totalAsset1 = asset1.balanceOf(address(this));
    uint256 totalAsset2ValueInAsset1 = _calculateReceivedAmount(
      address(asset2),
      address(asset1),
      asset2.balanceOf(address(this))
    );

    return totalAsset1 + totalAsset2ValueInAsset1;
  }

  /**
   * @dev Returns the total liquidity in asset2.
   * The total liquidity is calculated by summing the balance of asset2 held by the contract
   * and the value of asset1 converted to asset2 using the _calculateReceivedAmount function.
   * @return The total liquidity in asset2.
   */
  function totalLiquidityInAsset2() public view returns (uint256) {
    uint256 totalAsset2 = asset2.balanceOf(address(this));
    uint256 totalAsset1ValueInAsset2 = _calculateReceivedAmount(
      address(asset1),
      address(asset2),
      asset1.balanceOf(address(this))
    );

    return totalAsset2 + totalAsset1ValueInAsset2;
  }

  /**
   * @dev Performs a rebalance if needed.
   *
   * This internal function checks if a rebalance is needed by calling the `checkRebalance` function of the `rebalancer` contract.
   * If a rebalance is required, it calls the `rebalance` function of the `rebalancer` contract to perform the rebalance.
   *
   * Requirements:
   * - The `assets` array must contain the addresses of the assets to rebalance.
   * - The `weights` array must contain the corresponding weights for the assets.
   * - The `rebalanceStatus` must not be `NoRebalance`.
   */
  function performRebalanceIfNeeded() internal {
    address[] memory assets = new address[](2);
    uint256[] memory weights = new uint256[](2);
    assets[0] = address(asset1);
    assets[1] = address(asset2);
    weights[0] = 5000;
    weights[1] = 5000;

    IBaluniV1Rebalancer.RebalanceType rebalanceStatus = rebalancer.checkRebalance(assets, weights, 100, address(this));
    if (rebalanceStatus != IBaluniV1Rebalancer.RebalanceType.NoRebalance) {
      rebalancer.rebalance(assets, weights, address(this), address(this));
    }
  }

  event Swap(
    address indexed user,
    address indexed fromToken,
    address indexed toToken,
    uint256 amountIn,
    uint256 amountOut
  );
  event LiquidityAdded(address indexed user, uint256 amount1, uint256 amount2, uint256 sharesMinted);
  event LiquidityRemoved(address indexed user, uint256 asset1Amount, uint256 asset2Amount, uint256 sharesBurned);
}
