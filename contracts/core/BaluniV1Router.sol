// SPDX-License-Identifier: MIT
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
import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';

import '../interfaces/IOracle.sol';
import '../interfaces/IBaluniV1RewardPool.sol';
import '../interfaces/IBaluniV1AgentFactory.sol';
import '../interfaces/IBaluniV1Agent.sol';

contract BaluniV1Router is
  Initializable,
  ERC20Upgradeable,
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable,
  UUPSUpgradeable
{
  using SafeERC20Upgradeable for IERC20Upgradeable;

  struct Call {
    address to;
    uint256 value;
    bytes data;
  }

  uint256 public _MAX_BPS_FEE;
  uint256 public _BPS_FEE;
  uint256 public _BPS_BASE;
  IBaluniV1RewardPool public rewardPool;
  EnumerableSetUpgradeable.AddressSet private tokens;
  IERC20Upgradeable private USDC;
  IERC20MetadataUpgradeable private WNATIVE;
  IOracle private oracle;
  ISwapRouter private uniswapRouter;
  IUniswapV3Factory private uniswapFactory;
  IBaluniV1AgentFactory public agentFactory;

  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

  event Execute(address user, IBaluniV1Agent.Call[] calls, address[] tokensReturn);
  event Burn(address user, uint256 value);
  event Mint(address user, uint256 value);
  event ChangeBpsFee(uint256 newFee);
  event ChangeRewardPool(address pool);

  modifier validTimestamp(uint256 _timestamp) {
    require(_timestamp <= block.timestamp, 'Timestamp too far in the future');
    require(_timestamp >= block.timestamp - 1 days, 'Timestamp too far in the past');
    _;
  }

  function initialize() public initializer {
    __ERC20_init('Baluni', 'BALUNI');
    __Ownable_init();
    __ReentrancyGuard_init();
    __UUPSUpgradeable_init();
    _mint(address(this), 1 ether);

    _MAX_BPS_FEE = 500;
    _BPS_FEE = 30; // 0.3%.
    _BPS_BASE = 10000;
    USDC = IERC20Upgradeable(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
    WNATIVE = IERC20MetadataUpgradeable(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
    oracle = IOracle(0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8); // 1inch Spot Aggregator
    uniswapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    uniswapFactory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    EnumerableSetUpgradeable.add(tokens, address(USDC));
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  function getBpsFee() external view returns (uint256) {
    return _BPS_FEE;
  }

  function getUnitPrice() public view returns (uint256) {
    return _calculateBaluniToUSDC(1e18);
  }

  function listAllTokens() external view returns (address[] memory) {
    return tokens.values();
  }

  function changeBpsFee(uint256 _newFee) external onlyOwner {
    _BPS_FEE = _newFee;
    emit ChangeBpsFee(_newFee);
  }

  function changeRewardPool(address _rewardPool) external onlyOwner {
    rewardPool = IBaluniV1RewardPool(_rewardPool);
    emit ChangeRewardPool(_rewardPool);
  }

  function changeAgentFactory(address _agentFactory) external onlyOwner {
    agentFactory = IBaluniV1AgentFactory(_agentFactory);
  }

  function execute(IBaluniV1Agent.Call[] memory calls, address[] memory tokensReturn) external nonReentrant {
    require(address(agentFactory) != address(0), 'Agent factory not set');
    address agent = agentFactory.getOrCreateAgent(msg.sender);

    bool[] memory isTokenNew = new bool[](tokensReturn.length);

    for (uint256 i = 0; i < tokensReturn.length; i++) {
      isTokenNew[i] = !EnumerableSetUpgradeable.contains(tokens, tokensReturn[i]);
    }
    IBaluniV1Agent(agent).execute(calls, tokensReturn);

    for (uint256 i = 0; i < tokensReturn.length; i++) {
      address token = tokensReturn[i];
      address poolNative3000 = uniswapFactory.getPool(token, address(WNATIVE), 3000);
      address poolNative500 = uniswapFactory.getPool(token, address(WNATIVE), 500);
      bool poolExist = poolNative3000 != address(0) || poolNative500 != address(0);

      if (isTokenNew[i] && poolExist) {
        EnumerableSetUpgradeable.add(tokens, token);
      }

      if (!poolExist) {
        uint256 balance = IERC20Upgradeable(token).balanceOf(address(this));
        IERC20Upgradeable(token).transfer(msg.sender, balance);
      }
    }
  }

  function liquidate(address token) external nonReentrant {
    uint256 totalERC20Balance = IERC20Upgradeable(token).balanceOf(address(this));
    address pool = uniswapFactory.getPool(token, address(USDC), 3000);
    secureApproval(token, address(uniswapRouter), totalERC20Balance);
    if (pool != address(0)) {
      uint256 singleSwapResult = _singleSwap(token, address(USDC), totalERC20Balance, address(this));
      require(singleSwapResult > 0, 'Swap Failed, Try Burn()');
    } else {
      uint256 amountOutHop = _multiHopSwap(token, address(WNATIVE), address(USDC), totalERC20Balance, address(this));
      require(amountOutHop > 0, 'Swap Failed, Try Burn()');
    }
  }

  function burnERC20(uint256 burnAmount) external nonReentrant {
    require(balanceOf(msg.sender) >= burnAmount, 'Insufficient BAL');
    _checkUSDC(burnAmount);

    for (uint256 i; i < tokens.length(); i++) {
      address token = tokens.at(i);
      uint256 totalBaluni = totalSupply();
      uint256 totalERC20Balance = IERC20Upgradeable(token).balanceOf(address(this));

      if (totalERC20Balance == 0 || token == address(this)) continue;

      uint256 decimals = IERC20MetadataUpgradeable(token).decimals();
      uint256 share = _calculateERC20Share(totalBaluni, totalERC20Balance, burnAmount, decimals);

      IERC20Upgradeable(token).transfer(msg.sender, share);
    }
    _burn(msg.sender, burnAmount);
    emit Burn(msg.sender, burnAmount);
  }

  function burnUSDC(uint256 burnAmount) external nonReentrant {
    require(burnAmount > 0, 'Insufficient BAL');
    _checkUSDC(burnAmount);

    for (uint256 i; i < tokens.length(); i++) {
      address token = tokens.at(i);
      uint256 totalBaluni = totalSupply();
      uint256 totalERC20Balance = IERC20Upgradeable(token).balanceOf(address(this));

      if (totalERC20Balance > 0 == false) continue;
      if (token == address(this)) continue;

      uint256 decimals = IERC20MetadataUpgradeable(token).decimals();
      uint256 burnAmountToken = _calculateERC20Share(totalBaluni, totalERC20Balance, burnAmount, decimals);

      if (token == address(USDC)) {
        IERC20Upgradeable(USDC).transfer(msg.sender, burnAmountToken);
        continue;
      }

      address pool = uniswapFactory.getPool(token, address(USDC), 3000);
      secureApproval(token, address(uniswapRouter), burnAmountToken);

      if (pool != address(0)) {
        _singleSwap(token, address(USDC), burnAmountToken, msg.sender);
      } else {
        uint256 amountOutHop = _multiHopSwap(token, address(WNATIVE), address(USDC), burnAmountToken, msg.sender);
        require(amountOutHop > 0, 'Swap Failed, Try Burn()');
      }
    }
    _burn(msg.sender, burnAmount);
    emit Burn(msg.sender, burnAmount);
  }

  function mintUSDC(uint256 balAmountToMint) public nonReentrant {
    uint256 totalUSDValuation = _totalValuation();
    uint256 totalBalSupply = totalSupply();
    uint256 usdcRequired = (balAmountToMint * totalUSDValuation) / totalBalSupply;
    USDC.safeTransferFrom(msg.sender, address(this), usdcRequired / 1e12);

    uint256 balance = IERC20Upgradeable(USDC).balanceOf(msg.sender);
    uint256 allowed = USDC.allowance(msg.sender, address(this));
    require(totalBalSupply > 0, 'Total BALUNI supply cannot be zero');
    require(balance >= usdcRequired / 1e12, 'USDC balance is insufficient');
    require(allowed >= usdcRequired / 1e12, 'Check the token allowance');

    _mint(msg.sender, balAmountToMint);
    emit Mint(msg.sender, balAmountToMint);

    if (address(rewardPool) == address(0)) return;

    uint256 usdcAmountAfterFee = _calculateNetAmountAfterFee(usdcRequired);
    uint256 usdcToSend = usdcRequired - usdcAmountAfterFee;

    approve(address(rewardPool), usdcToSend / 1e12);
    rewardPool.notifyRewardAmount(address(USDC), usdcToSend / 1e12, 30 days);
  }

  function mintERC20(uint256 balAmountToMint, address asset) public nonReentrant {
    uint256 totalUSDValuation = _totalValuation();
    uint256 totalBalSupply = totalSupply();
    require(totalBalSupply > 0, 'Total BALUNI supply cannot be zero');

    uint256 usdcRequired = (balAmountToMint * totalUSDValuation) / totalBalSupply;
    uint8 decimalA = IERC20MetadataUpgradeable(address(USDC)).decimals();
    uint8 decimalB = IERC20MetadataUpgradeable(asset).decimals();
    uint256 assetRate = oracle.getRate(IERC20Upgradeable(USDC), IERC20Upgradeable(asset), false);
    uint256 required;

    if (decimalB > decimalA) {
      uint256 rate = assetRate / 10 ** (decimalB - decimalA);
      required = (usdcRequired / rate) * 1e18;
      required = required / 10 ** (decimalB - decimalA);
    } else {
      uint256 rate = assetRate * 10 ** (decimalA - decimalB);
      required = (usdcRequired / rate) * 1e18;
      required = required / 10 ** (decimalA - decimalB);
    }

    uint256 balance = IERC20Upgradeable(asset).balanceOf(msg.sender);
    require(balance >= required, 'Balance is insufficient');

    uint256 allowed = IERC20Upgradeable(asset).allowance(msg.sender, address(this));
    require(allowed >= required, 'Check the token allowance');

    IERC20Upgradeable(asset).safeTransferFrom(msg.sender, address(this), required);

    _mint(msg.sender, balAmountToMint);
    emit Mint(msg.sender, balAmountToMint);

    if (address(rewardPool) == address(0)) return;

    uint256 amountAfterFee = _calculateNetAmountAfterFee(required);
    uint256 toSend = required - amountAfterFee;

    IERC20Upgradeable(asset).approve(address(rewardPool), toSend);

    rewardPool.notifyRewardAmount(address(USDC), toSend, 30 days);
  }

  function calculateTokenShare(
    uint256 totalBaluni,
    uint256 totalERC20Balance,
    uint256 baluniAmount,
    uint256 tokenDecimals
  ) external pure returns (uint256) {
    return _calculateERC20Share(totalBaluni, totalERC20Balance, baluniAmount, tokenDecimals);
  }

  function tokenValuation(uint256 amount, address token) external view returns (uint256) {
    return _calculateERC20Valuation(amount, token);
  }

  function totalValuation() external view returns (uint256) {
    return _totalValuation();
  }

  function getUSDCShareValue(uint256 amount) external view returns (uint256) {
    return _calculateBaluniToUSDC(amount);
  }

  function performArbitrage() external nonReentrant {
    uint256 unitPrice = getUnitPrice();
    uint256 marketPrice = oracle.getRate(IERC20Upgradeable(address(this)), IERC20Upgradeable(address(USDC)), false);
    marketPrice = marketPrice * 1e12;
    uint256 baluniBalance = balanceOf(address(this));
    uint256 usdcBalance = IERC20Upgradeable(USDC).balanceOf(address(this));
    usdcBalance = usdcBalance * 1e12;

    if (marketPrice < unitPrice) {
      uint256 amountToBuy = ((usdcBalance) / (marketPrice)) * 1e18;

      if (amountToBuy > baluniBalance) amountToBuy = baluniBalance;

      require(amountToBuy > 0, 'Arbitrage failed: insufficient BALUNI balance');
      require(usdcBalance > 0, 'Arbitrage failed: insufficient USDC balance');
      secureApproval(address(USDC), address(uniswapRouter), usdcBalance);
      uint256 amountOut = _singleSwap(address(USDC), address(this), usdcBalance, address(this));
      require(amountOut >= amountToBuy, 'Arbitrage failed: insufficient output amount');
      secureApproval(address(this), address(uniswapRouter), amountOut);
      _singleSwap(address(this), address(USDC), amountOut, address(this));

      require(IERC20Upgradeable(USDC).balanceOf(address(this)) > usdcBalance, 'Arbitrage did not profit');
    } else if (marketPrice > unitPrice) {
      uint256 amountToSell = baluniBalance;
      require(amountToSell > 0, 'Arbitrage failed: insufficient BALUNI balance');
      require(usdcBalance > 0, 'Arbitrage failed: insufficient USDC balance');
      secureApproval(address(this), address(uniswapRouter), amountToSell);
      uint256 amountOutUSDC = _singleSwap(address(this), address(USDC), amountToSell, address(this));
      require(amountOutUSDC > usdcBalance, 'Arbitrage failed: insufficient output amount');
      secureApproval(address(USDC), address(uniswapRouter), amountOutUSDC);
      _singleSwap(address(USDC), address(this), amountOutUSDC, address(this));
      require(balanceOf(address(this)) > baluniBalance, 'Arbitrage did not profit');
    }
  }

  function secureApproval(address token, address spender, uint256 amount) internal {
    IERC20Upgradeable _token = IERC20Upgradeable(token);
    uint256 currentAllowance = _token.allowance(address(this), spender);

    if (currentAllowance != amount) {
      if (currentAllowance != 0) {
        _token.approve(spender, 0);
      }
      _token.approve(spender, amount);
    }
  }

  function _calculateERC20Valuation(uint256 amount, address token) internal view returns (uint256 valuation) {
    uint256 rate;
    uint8 tokenDecimal = IERC20MetadataUpgradeable(token).decimals();
    uint8 usdcDecimal = IERC20MetadataUpgradeable(address(USDC)).decimals();

    if (token == address(USDC)) return amount * 1e12;

    try IOracle(oracle).getRate(IERC20Upgradeable(token), IERC20Upgradeable(USDC), false) returns (uint256 _rate) {
      rate = _rate;
    } catch {
      return 0;
    }

    uint256 factor = (10 ** (tokenDecimal - usdcDecimal));

    if (tokenDecimal < 18) return ((amount * factor) * (rate * factor)) / 1e18;

    return ((amount) * (rate * factor)) / 1e18;
  }

  function _calculateBaluniToUSDC(uint256 amount) internal view returns (uint256 shareUSDC) {
    uint256 totalBaluni = totalSupply();
    require(totalBaluni > 0, 'Total supply cannot be zero');
    uint256 totalUSDC = _totalValuation();
    shareUSDC = (amount * totalUSDC) / totalBaluni;
  }

  function _calculateERC20Share(
    uint256 totalBaluni,
    uint256 totalERC20Balance,
    uint256 baluniAmount,
    uint256 tokenDecimals
  ) internal pure returns (uint256) {
    require(totalBaluni > 0, 'Total supply cannot be zero');
    require(tokenDecimals <= 18, 'Token decimals should be <= 18');
    uint256 baluniAdjusted;
    uint256 amountAdjusted;

    if (tokenDecimals < 18) {
      baluniAdjusted = totalBaluni / (10 ** (18 - tokenDecimals));
      amountAdjusted = baluniAmount / (10 ** (18 - tokenDecimals));
    } else {
      baluniAdjusted = totalBaluni;
      amountAdjusted = baluniAmount;
    }

    uint256 result = (amountAdjusted * totalERC20Balance) / baluniAdjusted;

    return result;
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

  function _totalValuation() internal view returns (uint256) {
    uint256 _totalV;

    for (uint256 i; i < tokens.length(); i++) {
      address token = tokens.at(i);
      uint256 balance = IERC20Upgradeable(token).balanceOf(address(this));
      uint256 tokenBalanceValuation = _calculateERC20Valuation(balance, token);
      _totalV += tokenBalanceValuation;
    }

    return _totalV;
  }

  function _calculateNetAmountAfterFee(uint256 _amount) internal view returns (uint256) {
    uint256 amountInWithFee = (_amount * (_BPS_BASE - (_BPS_FEE))) / _BPS_BASE;
    return amountInWithFee;
  }

  function _checkUSDC(uint256 amountToBurn) internal view {
    uint256 balance = IERC20Upgradeable(USDC).balanceOf(address(this));
    if (balance >= 0.001 * 1e6 && totalSupply() >= 1) {
      require(amountToBurn >= 0.01 ether, 'Minimum burn amount is 0.01 BALUNI');
    }
  }

  function _resize(uint256[] memory arr, uint256 size) internal pure returns (uint256[] memory) {
    uint256[] memory ret = new uint256[](size);
    for (uint256 i; i < size; i++) {
      ret[i] = arr[i];
    }
    return ret;
  }

  function getVersion() external pure returns (string memory) {
    return 'v1.0.1';
  }
}
