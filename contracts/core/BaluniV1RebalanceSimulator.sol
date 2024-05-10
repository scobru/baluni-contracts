import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/interfaces/IERC20.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';

import './BaluniV1Agent.sol';
import './BaluniV1Stake.sol';

interface IOracle {
  function getRate(IERC20 srcToken, IERC20 dstToken, bool useWrappers) external view returns (uint256 weightedRate);
}

interface IBaluniRouter {
  function getAgentAddress(address _user) external returns (address);

  function tokenValuation(uint256 amount, address token) external returns (uint256);
}

contract BaluniV1RebalanceSimulator is Ownable {
  struct Call {
    address to;
    uint256 value;
    bytes data;
  }

  IBaluniRouter public baluniRouter;

  IERC20 public constant USDC = IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
  IERC20Metadata internal constant WNATIVE = IERC20Metadata(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
  IOracle public immutable oracle = IOracle(0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8); // 1inch Spot Aggregator
  ISwapRouter public immutable uniswapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
  IUniswapV3Factory public immutable uniswapFactory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

  constructor(address _baluniRouter) Ownable(msg.sender) {
    baluniRouter = IBaluniRouter(_baluniRouter);
  }

  function simulateRebalance(
    address[] calldata assets,
    uint256[] calldata weights
  ) external returns (Call[] memory, Call[] memory, Call[] memory, Call[] memory) {
    uint256 totalValue;
    address agentAddress = baluniRouter.getAgentAddress(msg.sender);
    Call[] memory callDatasSell = new Call[](assets.length * 2);
    Call[] memory callDatasBuy = new Call[](assets.length * 2);

    Call[] memory approvalsSell = new Call[](assets.length * 2);
    Call[] memory approvalsBuy = new Call[](assets.length * 2);

    for (uint256 i; i < assets.length; i++) {
      uint256 balance = IERC20(assets[i]).balanceOf(msg.sender);
      uint256 tokenValuation = baluniRouter.tokenValuation(balance, assets[i]);
      totalValue += tokenValuation;
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
      uint256 balance = IERC20(assets[i]).balanceOf(msg.sender);
      uint256 decimals = IERC20Metadata(assets[i]).decimals();
      uint256 tokensTotalValue = baluniRouter.tokenValuation(balance, assets[i]);
      targetWeight = weights[i];
      currentWeight = tokensTotalValue / (10000) / (totalValue);
      overweight = currentWeight > targetWeight;
      overweightPercent = overweight ? currentWeight - (targetWeight) : targetWeight - (currentWeight);
      uint256 price = baluniRouter.tokenValuation(1 * 10 ** decimals, assets[i]);
      if (overweight) {
        overweightAmount = (overweightPercent * (totalValue)) / (10000);
        overweightAmount = (overweightAmount * (1e18)) / (price);
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
        bytes memory data = abi.encodeWithSignature('approve(address,uint256)', address(this), overweightAmounts[i]);
        bytes memory tx = abi.encode(assets[overweightVaults[i]], 0, data);

        Call memory txData = Call(assets[overweightVaults[i]], 0, data);

        approvalsSell[i] = txData;

        data = abi.encodeWithSignature(
          'transferFrom(address,address,uint256)',
          msg.sender,
          address(this),
          overweightAmounts[i]
        );

        txData = Call(assets[overweightVaults[i]], 0, data);

        callDatasSell[i] = txData;

        address pool = uniswapFactory.getPool(address(assets[overweightVaults[i]]), address(USDC), 3000);

        // encode the calldata for the IERC20(assets[overweightVaults[i]])

        data = pool != address(0)
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

        txData = Call(address(this), 0, data);

        callDatasSell[i + 1] = txData;
      }
    }
    for (uint256 i; i < underweightVaults.length; i++) {
      if (underweightAmounts[i] > 0) {
        bytes memory data = abi.encodeWithSignature(
          'approve(address,uint256)',
          address(agentAddress),
          underweightVaults[i]
        );

        Call memory txData = Call(address(USDC), 0, data);

        approvalsBuy[i] = txData;

        data = abi.encodeWithSignature(
          'transferFrom(address,address,uint256)',
          msg.sender,
          address(this),
          underweightVaults[i]
        );

        txData = Call(assets[underweightVaults[i]], 0, data);

        callDatasBuy[i] = txData;

        uint256 rebaseActiveWgt = (underweightAmounts[i] * (10000)) / (totalActiveWeight);

        uint256 rebBuyQty = (rebaseActiveWgt * IERC20(USDC).balanceOf(msg.sender) * 1e12) / (10000);

        if (rebBuyQty > 0 && rebBuyQty <= IERC20(USDC).balanceOf(msg.sender) * 1e12) {
          address pool = uniswapFactory.getPool(address(assets[underweightVaults[i]]), address(USDC), 3000);
          if (pool != address(0)) {
            data = pool != address(0)
              ? abi.encodeWithSignature(
                'singleSwap(address,address,uint256,address)',
                address(USDC),
                address(assets[underweightVaults[i]]),
                underweightAmounts[i] / 1e12,
                msg.sender
              )
              : abi.encodeWithSignature(
                'multiHopSwap(address,address,address,uint256,address)',
                address(USDC),
                address(WNATIVE),
                address(assets[underweightVaults[i]]),
                underweightAmounts[i] / 1e12,
                msg.sender
              );

            txData = Call(address(this), 0, data);

            callDatasSell[i + 1] = txData;
          }
        }
      }
    }
    return (approvalsSell, approvalsBuy, callDatasSell, callDatasBuy);
  }

  function _resize(uint256[] memory arr, uint256 size) internal pure returns (uint256[] memory) {
    uint256[] memory ret = new uint256[](size);
    for (uint256 i; i < size; i++) {
      ret[i] = arr[i];
    }
    return ret;
  }
}
