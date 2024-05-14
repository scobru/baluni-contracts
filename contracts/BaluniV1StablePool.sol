// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import './interfaces/IBaluniV1Rebalancer.sol';

interface IOracle {
  function getRate(
    IERC20 srcToken,
    IERC20 dstToken,
    bool useWrappers
  ) external view returns (uint256 weightedRate);
}

contract BaluniV1StablePool is ERC20, ReentrancyGuard {
  using SafeERC20 for IERC20;

  IBaluniV1Rebalancer public rebalancer;
  IERC20 public asset1;
  IERC20 public asset2;
  IOracle public oracle;

  uint256 public constant SWAP_FEE_BPS = 30;

  constructor(
    address _oracle,
    address _rebalancer,
    address _asset1,
    address _asset2
  ) ERC20('Baluni StableLP', 'BALUNI-SLP') {
    rebalancer = IBaluniV1Rebalancer(_rebalancer);
    asset1 = IERC20(_asset1);
    asset2 = IERC20(_asset2);
    oracle = IOracle(_oracle);

    asset1.approve(address(rebalancer), type(uint256).max);
    asset2.approve(address(rebalancer), type(uint256).max);
  }

  function calculateReceivedAmount(
    address fromToken,
    address toToken,
    uint256 amountAfterFee
  ) public view returns (uint256) {
    // Getting rate from the oracle
    uint256 rate = oracle.getRate(IERC20(fromToken), IERC20(toToken), true);

    // Adjusting for token decimals
    uint8 fromDecimals = IERC20Metadata(fromToken).decimals();
    uint8 toDecimals = IERC20Metadata(toToken).decimals();

    // Calculate received amount considering the decimals
    uint256 receivedAmount;
    if (fromDecimals > toDecimals) {
      receivedAmount =
        (amountAfterFee * rate) /
        (10 ** (fromDecimals - toDecimals));
    } else if (toDecimals > fromDecimals) {
      receivedAmount =
        (amountAfterFee * rate) *
        (10 ** (toDecimals - fromDecimals));
    } else {
      receivedAmount = (amountAfterFee * rate);
    }

    return receivedAmount / 1e18;
  }

  function swap(
    address fromToken,
    address toToken,
    uint256 amount
  ) external nonReentrant {
    require(
      (fromToken == address(asset1) || fromToken == address(asset2)) &&
        (toToken == address(asset1) || toToken == address(asset2)),
      'Unsupported token'
    );
    require(fromToken != toToken, 'Cannot swap the same token');
    require(amount > 0, 'Amount must be greater than zero');

    IERC20(fromToken).safeTransferFrom(msg.sender, address(this), amount);

    uint256 fee = (amount * SWAP_FEE_BPS) / 10000;
    uint256 amountAfterFee = amount - fee;

    uint256 receivedAmount = calculateReceivedAmount(
      fromToken,
      toToken,
      amountAfterFee
    );

    IERC20(toToken).safeTransfer(msg.sender, receivedAmount);
  }

  function provideLiquidity(
    uint256 amount1,
    uint256 amount2
  ) external nonReentrant {
    performRebalanceIfNeeded();
    asset1.safeTransferFrom(msg.sender, address(this), amount1);
    asset2.safeTransferFrom(msg.sender, address(this), amount2);

    // Calculate the equivalent value of each asset in terms of a base token (e.g., asset1)
    uint256 totalValue1 = amount1; // direct value of asset1
    uint256 totalValue2 = calculateReceivedAmount(
      address(asset2),
      address(asset1),
      amount2
    ); // convert asset2 to asset1

    uint256 totalValue = totalValue1 + totalValue2;
    _mint(msg.sender, totalValue);

    performRebalanceIfNeeded();
  }

  function removeLiquidity(uint256 share) external nonReentrant {
    require(balanceOf(msg.sender) >= share, 'Insufficient share');
    uint256 totalSupply = totalSupply();

    uint256 totalValue = calculatePoolValue();

    // Calculate the total asset value the user should receive based on their share
    uint256 userValue = (totalValue * share) / totalSupply;
    uint256 shareAsset1 = calculateAssetShareFromValue(
      userValue,
      address(asset1)
    );
    uint256 shareAsset2 = userValue - shareAsset1; // Ensure preservation of total value

    _burn(msg.sender, share);
    asset1.safeTransfer(msg.sender, shareAsset1);
    asset2.safeTransfer(msg.sender, shareAsset2);

    performRebalanceIfNeeded();
  }

  function calculatePoolValue() internal view returns (uint256) {
    uint256 totalAsset1 = asset1.balanceOf(address(this)) *
      (10 ** (18 - IERC20Metadata(address(asset1)).decimals()));
    uint256 totalAsset2ValueInAsset1 = calculateReceivedAmount(
      address(asset2),
      address(asset1),
      asset2.balanceOf(address(this))
    ) * (10 ** (18 - IERC20Metadata(address(asset1)).decimals()));

    return totalAsset1 + totalAsset2ValueInAsset1;
  }

  function calculateAssetShareFromValue(
    uint256 value,
    address asset
  ) internal view returns (uint256) {
    uint256 rate = oracle.getRate(IERC20(asset), asset1, true); // Assume rate is from asset to asset1
    uint256 decimalsDiff = 18 +
      IERC20Metadata(address(asset1)).decimals() -
      IERC20Metadata(asset).decimals();
    return (value * 10 ** decimalsDiff) / rate;
  }

  function performRebalanceIfNeeded() internal {
    address[] memory assets = new address[](2);
    uint256[] memory weights = new uint256[](2);

    assets[0] = address(asset1);
    assets[1] = address(asset2);

    weights[0] = 5000; // Represents 50% in a 10,000 basis format
    weights[1] = 5000; // Represents 50%

    IBaluniV1Rebalancer.RebalanceType rebalanceStatus = rebalancer
      .checkRebalance(assets, weights, 5, address(this));

    if (rebalanceStatus != IBaluniV1Rebalancer.RebalanceType.NoRebalance) {
      rebalancer.rebalance(assets, weights, address(this), address(this));
    }
  }
}
