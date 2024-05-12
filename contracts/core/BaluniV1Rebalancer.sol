// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

interface IOracle {
  function getRate(
    IERC20Upgradeable srcToken,
    IERC20Upgradeable dstToken,
    bool useWrappers
  ) external view returns (uint256 weightedRate);
}

interface IBaluniRouter {
  function getAgentAddress(address _user) external view returns (address);

  function getBpsFee() external view returns (uint256);

  function tokenValuation(uint256 amount, address token) external view returns (uint256);
}

contract BaluniV1Rebalancer is Initializable, OwnableUpgradeable, UUPSUpgradeable {
  struct Call {
    address to;
    uint256 value;
    bytes data;
  }

  uint256 private multiplier;
  IBaluniRouter public baluniRouter;
  IERC20Upgradeable private USDC;
  IERC20MetadataUpgradeable private WNATIVE;
  IOracle private oracle;
  ISwapRouter private uniswapRouter;
  IUniswapV3Factory private uniswapFactory;

  function initialize(address _baluniRouter) public initializer {
    __UUPSUpgradeable_init();
    __Ownable_init();
    USDC = IERC20Upgradeable(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
    WNATIVE = IERC20MetadataUpgradeable(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
    oracle = IOracle(0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8); // 1inch Spot Aggregator
    uniswapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    uniswapFactory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    baluniRouter = IBaluniRouter(_baluniRouter);
    multiplier = 1e12;
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  function getTokenValuation(uint256 amount, address token) internal view returns (uint256) {
    return baluniRouter.tokenValuation(amount, token);
  }

  function executeDirect(Call[] calldata calls) external {
    for (uint256 i = 0; i < calls.length; i++) {
      (bool success, ) = calls[i].to.call{value: calls[i].value}(calls[i].data);
      require(success, 'Batch call failed');
    }
  }

  function rebalanceCalldatas(
    address[] calldata assets,
    uint256[] calldata weights
  ) external view returns (Call[] memory, Call[] memory, Call[] memory, Call[] memory) {
    uint256 finalUsdBalance;
    uint256 totalValue;
    address agentAddress = baluniRouter.getAgentAddress(msg.sender);

    Call[] memory callDatasSell = new Call[](assets.length * 2);
    Call[] memory callDatasBuy = new Call[](assets.length * 2);

    Call[] memory approvalsSell = new Call[](assets.length * 2);
    Call[] memory approvalsBuy = new Call[](assets.length * 2);

    for (uint256 i; i < assets.length; i++) {
      uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(msg.sender);
      totalValue += getTokenValuation(balance, address(assets[i]));
    }

    uint256[] memory overweightVaults = new uint256[](assets.length);
    uint256[] memory overweightAmounts = new uint256[](assets.length);
    uint256[] memory underweightVaults = new uint256[](assets.length);
    uint256[] memory underweightAmounts = new uint256[](assets.length);

    uint256 overweightVaultsLength;
    uint256 underweightVaultsLength;
    uint256 overweightAmount;
    uint256 overweightPercent;
    uint256 targetWeight;
    uint256 currentWeight;
    uint256 totalActiveWeight;

    bool overweight;

    for (uint256 i; i < assets.length; i++) {
      if (assets[i] == address(USDC)) continue;
      uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(msg.sender);
      uint256 decimals = IERC20MetadataUpgradeable(assets[i]).decimals();
      uint256 totalTokensValuation = getTokenValuation(balance, assets[i]);
      targetWeight = weights[i];
      currentWeight = totalTokensValuation / (10000) / (totalValue);
      overweight = currentWeight > targetWeight;
      overweightPercent = overweight ? currentWeight - (targetWeight) : targetWeight - (currentWeight);
      uint256 price = baluniRouter.tokenValuation(1 * 10 ** decimals, assets[i]);
      if (overweight) {
        overweightAmount = (overweightPercent * (totalValue)) / (10000);
        finalUsdBalance += overweightAmount;

        overweightAmount = (overweightAmount * (1e18)) / (price);
        if (decimals != uint8(18)) {
          overweightAmount = overweightAmount / (10 ** (18 - decimals));
        }
        overweightVaults[overweightVaultsLength] = i;
        overweightAmounts[overweightVaultsLength] = overweightAmount;
        overweightVaultsLength++;
      } else if (!overweight) {
        totalActiveWeight += overweightPercent;
        overweightAmount = overweightPercent;
        // overweightAmount = overweightPercent.mul(totalValue).div(10000);
        underweightVaults[underweightVaultsLength] = i;
        underweightAmounts[underweightVaultsLength] = overweightAmount;
        underweightVaultsLength++;
      }
    }

    // Resize overweightVaults and overweightAmounts to the actual overweighted vaults
    overweightVaults = _resize(overweightVaults, overweightVaultsLength);
    overweightAmounts = _resize(overweightAmounts, overweightVaultsLength);
    // Resize overweightVaults and overweightAmounts to the actual overweighted vaults
    underweightVaults = _resize(underweightVaults, underweightVaultsLength);
    underweightAmounts = _resize(underweightAmounts, underweightVaultsLength);

    for (uint256 i; i < overweightVaults.length; i++) {
      if (overweightAmounts[i] > 0) {
        Call memory txData = secureApprovalCalldata(
          assets[overweightVaults[i]],
          msg.sender,
          address(baluniRouter),
          overweightAmounts[i]
        );

        approvalsSell[i] = txData;

        address pool = uniswapFactory.getPool(address(assets[overweightVaults[i]]), address(USDC), 3000);

        bytes memory data = pool != address(0)
          ? abi.encodeWithSignature(
            'singleSwap(address,address,uint256,address)',
            address(assets[overweightVaults[i]]),
            address(USDC),
            overweightAmounts[i],
            msg.sender
          )
          : abi.encodeWithSignature(
            'multiHopSwap(address,address,address,uint256,address)',
            address(assets[overweightVaults[i]]),
            address(WNATIVE),
            address(USDC),
            overweightAmounts[i],
            msg.sender
          );

        txData = Call(address(baluniRouter), 0, data);
        callDatasSell[i] = txData;
      }
    }
    for (uint256 i; i < underweightVaults.length; i++) {
      if (underweightAmounts[i] > 0) {
        Call memory txData = secureApprovalCalldata(
          address(USDC),
          msg.sender,
          address(baluniRouter),
          underweightAmounts[i] / multiplier
        );
        approvalsBuy[i] = txData;

        uint256 rebaseActiveWgt = (underweightAmounts[i] * (10000)) / (totalActiveWeight);

        uint256 rebBuyQty = (rebaseActiveWgt * finalUsdBalance) / (10000);

        if (rebBuyQty > 0 && rebBuyQty <= finalUsdBalance) {
          address pool = uniswapFactory.getPool(address(assets[underweightVaults[i]]), address(USDC), 3000);

          bytes memory data = pool != address(0)
            ? abi.encodeWithSignature(
              'singleSwap(address,address,uint256,address)',
              address(USDC),
              address(assets[underweightVaults[i]]),
              rebBuyQty / multiplier,
              msg.sender
            )
            : abi.encodeWithSignature(
              'multiHopSwap(address,address,address,uint256,address)',
              address(USDC),
              address(WNATIVE),
              address(assets[underweightVaults[i]]),
              rebBuyQty / multiplier,
              msg.sender
            );

          txData = Call(address(baluniRouter), 0, data);
          callDatasBuy[i] = txData;
        }
      }
    }
    return (approvalsSell, approvalsBuy, callDatasSell, callDatasBuy);
  }

  function checkPortfolio(
    address[] calldata assets,
    uint256[] calldata weights,
    uint256 limit
  ) external returns (bool) {
    uint256 totalValue;

    for (uint256 i; i < assets.length; i++) {
      uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(msg.sender);
      uint256 _tokenValuation = getTokenValuation(balance, assets[i]);
      totalValue += _tokenValuation;
    }

    uint256[] memory overweightVaults = new uint256[](assets.length);
    uint256[] memory overweightAmounts = new uint256[](assets.length);
    uint256[] memory underweightVaults = new uint256[](assets.length);
    uint256[] memory underweightAmounts = new uint256[](assets.length);

    uint256 overweightVaultsLength;
    uint256 underweightVaultsLength;
    uint256 overweightAmount;
    uint256 overweightPercent;
    uint256 targetWeight;
    uint256 currentWeight;
    uint256 totalActiveWeight;

    bool overweight;

    for (uint256 i; i < assets.length; i++) {
      uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(msg.sender);
      uint256 decimals = IERC20MetadataUpgradeable(assets[i]).decimals();
      uint256 tokensTotalValue = getTokenValuation(balance, assets[i]);
      targetWeight = weights[i];
      currentWeight = tokensTotalValue / (10000) / (totalValue);
      overweight = currentWeight > targetWeight;
      overweightPercent = overweight ? currentWeight - (targetWeight) : targetWeight - (currentWeight);

      uint256 price = getTokenValuation(balance, assets[i]);

      if (overweightPercent > limit) {
        if (overweight) {
          return true;
        } else if (!overweight) {
          return true;
        }
      } else {
        return false;
      }
    }

    // Resize overweightVaults and overweightAmounts to the actual overweighted vaults
    overweightVaults = _resize(overweightVaults, overweightVaultsLength);
    overweightAmounts = _resize(overweightAmounts, overweightVaultsLength);
    // Resize overweightVaults and overweightAmounts to the actual overweighted vaults
    underweightVaults = _resize(underweightVaults, underweightVaultsLength);
    underweightAmounts = _resize(underweightAmounts, underweightVaultsLength);

    for (uint256 i; i < overweightVaults.length; i++) {
      if (overweightAmounts[i] > 0) {
        IERC20Upgradeable(address(assets[overweightVaults[i]])).transferFrom(
          msg.sender,
          address(this),
          overweightAmounts[i]
        );
        address pool = uniswapFactory.getPool(address(assets[overweightVaults[i]]), address(USDC), 3000);
        secureApproval(address(assets[overweightVaults[i]]), address(uniswapRouter), overweightAmounts[i]);

        if (pool != address(0)) {
          uint256 singleSwapResult = _singleSwap(
            address(assets[overweightVaults[i]]),
            address(USDC),
            overweightAmounts[i],
            underweightVaults.length == 0 ? msg.sender : address(this)
          );
        } else {
          uint256 amountOutHop = _multiHopSwap(
            address(assets[overweightVaults[i]]),
            address(WNATIVE),
            address(USDC),
            overweightAmounts[i],
            underweightVaults.length == 0 ? msg.sender : address(this)
          );
        }
      }
    }
    for (uint256 i; i < underweightVaults.length; i++) {
      if (underweightAmounts[i] > 0) {
        uint256 rebaseActiveWgt = (underweightAmounts[i] * (10000)) / (totalActiveWeight);
        uint256 rebBuyQty = (rebaseActiveWgt * IERC20Upgradeable(USDC).balanceOf(msg.sender) * 1e12) / (10000);

        if (rebBuyQty > 0 && rebBuyQty <= IERC20Upgradeable(USDC).balanceOf(msg.sender) * 1e12) {
          address pool = uniswapFactory.getPool(address(assets[underweightVaults[i]]), address(USDC), 3000);
          secureApproval(address(assets[underweightVaults[i]]), address(uniswapRouter), rebBuyQty / 1e12);

          if (pool != address(0)) {
            uint256 singleSwapResult = _singleSwap(
              address(USDC),
              address(assets[underweightVaults[i]]),
              rebBuyQty / 1e12,
              address(this)
            );

            uint256 amountToTransfer = calculateNetAmountAfterFee(singleSwapResult);
            IERC20Upgradeable(USDC).transfer(msg.sender, amountToTransfer);
            require(singleSwapResult > 0, 'Swap Failed, Try Burn()');
          } else {
            uint256 amountOutHop = _multiHopSwap(
              address(USDC),
              address(WNATIVE),
              address(assets[underweightVaults[i]]),
              rebBuyQty / 1e12,
              address(this)
            );

            uint256 amountToTransfer = calculateNetAmountAfterFee(amountOutHop);
            IERC20Upgradeable(USDC).transfer(msg.sender, amountToTransfer);
            require(amountOutHop > 0, 'Swap Failed');
          }
        }
      }
    }
    return true;
  }

  function rebalance(address[] calldata assets, uint256[] calldata weights) external returns (bool) {
    uint256 totalValue;

    for (uint256 i; i < assets.length; i++) {
      uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(msg.sender);
      uint256 _tokenValuation = getTokenValuation(balance, assets[i]);
      totalValue += _tokenValuation;
    }

    uint256[] memory overweightVaults = new uint256[](assets.length);
    uint256[] memory overweightAmounts = new uint256[](assets.length);
    uint256[] memory underweightVaults = new uint256[](assets.length);
    uint256[] memory underweightAmounts = new uint256[](assets.length);

    uint256 overweightVaultsLength;
    uint256 underweightVaultsLength;
    uint256 overweightAmount;
    uint256 overweightPercent;
    uint256 targetWeight;
    uint256 currentWeight;
    uint256 totalActiveWeight;

    bool overweight;

    for (uint256 i; i < assets.length; i++) {
      uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(msg.sender);
      uint256 decimals = IERC20MetadataUpgradeable(assets[i]).decimals();
      uint256 tokensTotalValue = getTokenValuation(balance, assets[i]);
      targetWeight = weights[i];
      currentWeight = tokensTotalValue / (10000) / (totalValue);
      overweight = currentWeight > targetWeight;
      overweightPercent = overweight ? currentWeight - (targetWeight) : targetWeight - (currentWeight);

      uint256 price = getTokenValuation(balance, assets[i]);

      if (overweight) {
        overweightAmount = (overweightPercent * (totalValue)) / (10000);
        overweightAmount = (overweightAmount * (1e18)) / (price);
        if (decimals != uint8(18)) {
          overweightAmount = overweightAmount * (10 ** (18 - decimals));
        }
        overweightVaults[overweightVaultsLength] = i;
        overweightAmounts[overweightVaultsLength] = overweightAmount;
        overweightVaultsLength++;
      } else if (!overweight) {
        totalActiveWeight += overweightPercent;
        overweightAmount = overweightPercent;
        // overweightAmount = overweightPercent.mul(totalValue).div(10000);
        underweightVaults[underweightVaultsLength] = i;
        underweightAmounts[underweightVaultsLength] = overweightAmount;
        underweightVaultsLength++;
      }
    }

    // Resize overweightVaults and overweightAmounts to the actual overweighted vaults
    overweightVaults = _resize(overweightVaults, overweightVaultsLength);
    overweightAmounts = _resize(overweightAmounts, overweightVaultsLength);
    // Resize overweightVaults and overweightAmounts to the actual overweighted vaults
    underweightVaults = _resize(underweightVaults, underweightVaultsLength);
    underweightAmounts = _resize(underweightAmounts, underweightVaultsLength);

    for (uint256 i; i < overweightVaults.length; i++) {
      if (overweightAmounts[i] > 0) {
        IERC20Upgradeable(address(assets[overweightVaults[i]])).transferFrom(
          msg.sender,
          address(this),
          overweightAmounts[i]
        );
        address pool = uniswapFactory.getPool(address(assets[overweightVaults[i]]), address(USDC), 3000);
        secureApproval(address(assets[overweightVaults[i]]), address(uniswapRouter), overweightAmounts[i]);

        if (pool != address(0)) {
          uint256 singleSwapResult = _singleSwap(
            address(assets[overweightVaults[i]]),
            address(USDC),
            overweightAmounts[i],
            underweightVaults.length == 0 ? msg.sender : address(this)
          );
        } else {
          uint256 amountOutHop = _multiHopSwap(
            address(assets[overweightVaults[i]]),
            address(WNATIVE),
            address(USDC),
            overweightAmounts[i],
            underweightVaults.length == 0 ? msg.sender : address(this)
          );
        }
      }
    }
    for (uint256 i; i < underweightVaults.length; i++) {
      if (underweightAmounts[i] > 0) {
        uint256 rebaseActiveWgt = (underweightAmounts[i] * (10000)) / (totalActiveWeight);
        uint256 rebBuyQty = (rebaseActiveWgt * IERC20Upgradeable(USDC).balanceOf(msg.sender) * 1e12) / (10000);

        if (rebBuyQty > 0 && rebBuyQty <= IERC20Upgradeable(USDC).balanceOf(msg.sender) * 1e12) {
          address pool = uniswapFactory.getPool(address(assets[underweightVaults[i]]), address(USDC), 3000);
          secureApproval(address(assets[underweightVaults[i]]), address(uniswapRouter), rebBuyQty / 1e12);

          if (pool != address(0)) {
            uint256 singleSwapResult = _singleSwap(
              address(USDC),
              address(assets[underweightVaults[i]]),
              rebBuyQty / 1e12,
              address(this)
            );

            uint256 amountToTransfer = calculateNetAmountAfterFee(singleSwapResult);
            IERC20Upgradeable(USDC).transfer(msg.sender, amountToTransfer);
            require(singleSwapResult > 0, 'Swap Failed, Try Burn()');
          } else {
            uint256 amountOutHop = _multiHopSwap(
              address(USDC),
              address(WNATIVE),
              address(assets[underweightVaults[i]]),
              rebBuyQty / 1e12,
              address(this)
            );

            uint256 amountToTransfer = calculateNetAmountAfterFee(amountOutHop);
            IERC20Upgradeable(USDC).transfer(msg.sender, amountToTransfer);
            require(amountOutHop > 0, 'Swap Failed');
          }
        }
      }
    }
    return true;
  }

  function _resize(uint256[] memory arr, uint256 size) internal pure returns (uint256[] memory) {
    uint256[] memory ret = new uint256[](size);
    for (uint256 i; i < size; i++) {
      ret[i] = arr[i];
    }
    return ret;
  }

  function secureApprovalCalldata(
    address token,
    address from,
    address to,
    uint256 amount
  ) internal view returns (Call memory) {
    IERC20Upgradeable _token = IERC20Upgradeable(token);
    uint256 currentAllowance = _token.allowance(address(from), address(to));
    if (amount > currentAllowance) {
      bytes memory data = abi.encodeWithSignature('approve(address,uint256)', to, amount);
      return Call(token, 0, data);
    } else {
      return Call(address(0), 0, '0x00');
    }
  }

  function secureApproval(address token, address spender, uint256 amount) internal {
    IERC20Upgradeable _token = IERC20Upgradeable(token);
    uint256 currentAllowance = _token.allowance(address(this), spender);

    if (amount > currentAllowance) {
      if (currentAllowance != 0) {
        _token.approve(spender, 0);
      }

      _token.approve(spender, amount);
    }
  }

  function singleSwap(
    address token0,
    address token1,
    uint256 amount,
    address receiver
  ) external returns (uint256 amountOut) {
    require(msg.sender != address(this), 'Wrong sender');
    require(amount > 0, 'Amount is 0');
    require(IERC20Upgradeable(token0).balanceOf(msg.sender) >= amount, 'Insufficient Balance');
    IERC20Upgradeable(token0).transferFrom(msg.sender, address(this), amount);
    secureApproval(token0, address(uniswapRouter), amount);
    return _singleSwap(token0, token1, amount, receiver);
  }

  function multiHopSwap(
    address token0,
    address token1,
    address token2,
    uint256 amount,
    address receiver
  ) external returns (uint256 amountOut) {
    require(msg.sender != address(this), 'Wrong sender');
    require(amount > 0, 'Amount is 0');
    require(IERC20Upgradeable(token0).balanceOf(msg.sender) >= amount, 'Insufficient Balance');
    IERC20Upgradeable(token0).transferFrom(msg.sender, address(this), amount);
    secureApproval(token0, address(uniswapRouter), amount);
    return _multiHopSwap(token0, token1, token2, amount, receiver);
  }

  function _singleSwap(
    address token0,
    address token1,
    uint256 tokenBalance,
    address receiver
  ) private returns (uint256 amountOut) {
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
      tokenIn: token0,
      tokenOut: token1,
      fee: 3000,
      recipient: address(receiver),
      deadline: block.timestamp,
      amountIn: tokenBalance,
      amountOutMinimum: 0,
      sqrtPriceLimitX96: 0
    });

    return uniswapRouter.exactInputSingle(params);
  }

  function _multiHopSwap(
    address token0,
    address token1,
    address token2,
    uint256 tokenBalance,
    address receiver
  ) private returns (uint256 amountOut) {
    ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
      path: abi.encodePacked(token0, uint24(3000), token1, uint24(3000), token2),
      recipient: address(receiver),
      deadline: block.timestamp,
      amountIn: tokenBalance,
      amountOutMinimum: 0
    });
    return uniswapRouter.exactInput(params);
  }

  function calculateNetAmountAfterFee(uint256 _amount) internal view returns (uint256) {
    uint256 _BPS_BASE = 10000;
    uint256 _BPS_FEE = baluniRouter.getBpsFee();
    uint256 amountInWithFee = (_amount * (_BPS_BASE - (_BPS_FEE))) / _BPS_BASE;
    return amountInWithFee;
  }
}
