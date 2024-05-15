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

  function totalLiquidityInAsset1() public view returns (uint256) {
    uint256 totalAsset1 = asset1.balanceOf(address(this));
    uint256 totalAsset2ValueInAsset1 = _calculateReceivedAmount(
      address(asset2),
      address(asset1),
      asset2.balanceOf(address(this))
    );

    return totalAsset1 + totalAsset2ValueInAsset1;
  }

  function totalLiquidityInAsset2() public view returns (uint256) {
    uint256 totalAsset2 = asset2.balanceOf(address(this));
    uint256 totalAsset1ValueInAsset2 = _calculateReceivedAmount(
      address(asset1),
      address(asset2),
      asset1.balanceOf(address(this))
    );

    return totalAsset2 + totalAsset1ValueInAsset2;
  }

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
