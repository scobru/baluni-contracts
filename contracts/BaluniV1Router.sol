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
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

import './interfaces/IBaluniV1AgentFactory.sol';
import './interfaces/IBaluniV1Agent.sol';
import './interfaces/IBaluniV1MarketOracle.sol';
import './interfaces/IBaluniV1Rebalancer.sol';
import './libs/EnumerableSetUpgradeable.sol';
import './BaluniToken.sol';
import './BaluniV1Uniswapper.sol';

interface I1inchSpotAgg {
  function getRate(IERC20 srcToken, IERC20 dstToken, bool useWrappers) external view returns (uint256 weightedRate);
}

contract BaluniV1Router is
  Initializable,
  BaluniToken,
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable,
  UUPSUpgradeable,
  BaluniV1Uniswapper
{
  struct Call {
    address to;
    uint256 value;
    bytes data;
  }

  uint256 public _MAX_BPS_FEE;
  uint256 public _BPS_FEE;
  uint256 public _BPS_BASE;

  EnumerableSetUpgradeable.AddressSet private tokens;
  IERC20 private USDC;
  IERC20Metadata private WNATIVE;
  I1inchSpotAgg private oracle;
  ISwapRouter private uniswapRouter;
  IUniswapV3Factory private uniswapFactory;
  IBaluniV1AgentFactory public agentFactory;
  IBaluniV1MarketOracle public marketOracle;
  IBaluniV1Rebalancer public rebalancer;

  address public treasury;

  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

  event Execute(address user, IBaluniV1Agent.Call[] calls, address[] tokensReturn);
  event Burn(address user, uint256 value);
  event Mint(address user, uint256 value);
  event ChangeBpsFee(uint256 newFee);
  event ChangeRewardPool(address pool);
  event Log(string message, uint256 value);

  /**
   * @dev Initializes the BaluniV1Router contract.
   * It sets the initial values for various variables and mints 1 ether to the contract's address.
   * It also sets the USDC token address, WNATIVE token address, oracle address, Uniswap router address, and Uniswap factory address.
   * Finally, it adds the USDC token address to the tokens set.
   */
  function initialize(
    address _usdc,
    address _wnative,
    address _1inchSpotAgg,
    address _uniRouter,
    address _uniFactory,
    address _rebalancer
  ) public initializer {
    __ERC20_init('Baluni', 'BALUNI');
    __Ownable_init(msg.sender);
    __ReentrancyGuard_init();
    __UUPSUpgradeable_init();
    _mint(address(this), 1 ether);

    _MAX_BPS_FEE = 500;
    _BPS_FEE = 30; // 0.3%.
    _BPS_BASE = 10000;
    USDC = IERC20(_usdc);
    WNATIVE = IERC20Metadata(_wnative);
    oracle = I1inchSpotAgg(_1inchSpotAgg); // 1inch Spot Aggregator
    uniswapRouter = ISwapRouter(_uniRouter);
    uniswapFactory = IUniswapV3Factory(_uniFactory);
    EnumerableSetUpgradeable.add(tokens, address(USDC));
    rebalancer = IBaluniV1Rebalancer(_rebalancer);
    treasury = msg.sender;
  }

  /**
   * @dev Reinitializes the BaluniV1Router contract with the specified parameters.
   * @param _usdc The address of the USDC token contract.
   * @param _wnative The address of the WNative token contract.
   * @param _1inchSpotAgg The address of the 1inch Spot Aggregator oracle contract.
   * @param _uniRouter The address of the Uniswap router contract.
   * @param _uniFactory The address of the Uniswap factory contract.
   * @param version The version of the contract.
   */
  function reinitialize(
    address _usdc,
    address _wnative,
    address _1inchSpotAgg,
    address _uniRouter,
    address _uniFactory,
    address _rebalancer,
    uint64 version
  ) public reinitializer(version) {
    // __UUPSUpgradeable_init();
    // __Ownable_init(msg.sender);
    _MAX_BPS_FEE = 500;
    _BPS_FEE = 30; // 0.3%.
    _BPS_BASE = 10000;
    USDC = IERC20(_usdc);
    WNATIVE = IERC20Metadata(_wnative);
    oracle = I1inchSpotAgg(_1inchSpotAgg); // 1inch Spot Aggregator
    uniswapRouter = ISwapRouter(_uniRouter);
    uniswapFactory = IUniswapV3Factory(_uniFactory);
    EnumerableSetUpgradeable.add(tokens, address(USDC));
    rebalancer = IBaluniV1Rebalancer(_rebalancer);
    treasury = msg.sender;
  }

  /**
   * @dev Initializes the market oracle contract.
   * @param _marketOracle The address of the market oracle contract.
   */
  function initializeMarketOracle(address _marketOracle) public initializer {
    require(address(marketOracle) == address(0), 'Market Oracle Already Initialized');
    marketOracle = IBaluniV1MarketOracle(_marketOracle);
  }

  /**
   * @dev Returns the address of the contract owner (treasury).
   * @return The address of the contract owner.
   */
  function getTreasury() public view returns (address) {
    return treasury;
  }

  /**
   * @dev Internal function to authorize an upgrade to a new implementation contract.
   * @param newImplementation The address of the new implementation contract.
   * @notice This function can only be called by the contract owner.
   */
  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  /**
   * @dev Returns the basis points fee.
   * @return The basis points fee as a uint256 value.
   */
  function getBpsFee() external view returns (uint256) {
    return _BPS_FEE;
  }

  /**
   * @dev Returns the unit price of the token in USDC.
   * @return The unit price of the token in USDC.
   */
  function unitPrice() public view returns (uint256) {
    return _calculateBaluniToUSDC(1e18);
  }

  /**
   * @dev Returns an array of all listed tokens.
   * @return An array of all listed tokens.
   */
  function listAllTokens() external view returns (address[] memory) {
    return tokens.values();
  }

  function changeMarketOracle(address _marketOracle) external onlyOwner {
    marketOracle = IBaluniV1MarketOracle(_marketOracle);
  }

  /**
   * @dev Changes the basis points fee for the contract.
   * @param _newFee The new basis points fee to be set.
   */
  function changeBpsFee(uint256 _newFee) external onlyOwner {
    _BPS_FEE = _newFee;
    emit ChangeBpsFee(_newFee);
  }

  /**
   * @dev Changes the treasury address.
   * Can only be called by the contract owner.
   * @param _newTreasury The new treasury address.
   */
  function changeTreasury(address _newTreasury) external onlyOwner {
    treasury = _newTreasury;
  }

  /**
   * @dev Changes the address of the rebalancer contract.
   * Can only be called by the contract owner.
   *
   * @param _newRebalancer The new address of the rebalancer contract.
   */
  function changeRebalancer(address _newRebalancer) external onlyOwner {
    rebalancer = IBaluniV1Rebalancer(_newRebalancer);
  }

  /**
   * @dev Changes the address of the agent factory contract.
   * Can only be called by the contract owner.
   * @param _agentFactory The new address of the agent factory contract.
   */
  function changeAgentFactory(address _agentFactory) external onlyOwner {
    agentFactory = IBaluniV1AgentFactory(_agentFactory);
  }

  /**
   * @dev Executes a series of calls to a BaluniV1Agent contract and handles token returns.
   * @param calls An array of IBaluniV1Agent.Call structs representing the calls to be executed.
   * @param tokensReturn An array of addresses representing the tokens to be returned.
   * @notice This function requires the agentFactory to be set and creates a new agent if necessary.
   * @notice If a token is new and a Uniswap pool exists for it, the token is added to the tokens set.
   * @notice If no Uniswap pool exists for a token, the token balance is transferred back to the caller.
   */
  function execute(IBaluniV1Agent.Call[] memory calls, address[] memory tokensReturn) external nonReentrant {
    require(address(agentFactory) != address(0), 'Agent factory not set');
    address agent = agentFactory.getOrCreateAgent(msg.sender);
    bool[] memory isTokenNew = new bool[](tokensReturn.length);
    uint256[] memory tokenBalances = new uint256[](tokensReturn.length);

    for (uint256 i = 0; i < tokensReturn.length; i++) {
      isTokenNew[i] = !EnumerableSetUpgradeable.contains(tokens, tokensReturn[i]);
      tokenBalances[i] = IERC20(tokensReturn[i]).balanceOf(address(this));
    }

    IBaluniV1Agent(agent).execute(calls, tokensReturn);

    for (uint256 i = 0; i < tokensReturn.length; i++) {
      address token = tokensReturn[i];
      uint256 balance = IERC20(token).balanceOf(address(this));

      address poolNative3000 = uniswapFactory.getPool(token, address(WNATIVE), 3000);
      address poolNative500 = uniswapFactory.getPool(token, address(WNATIVE), 500);
      address poolUSDC500 = uniswapFactory.getPool(token, address(USDC), 500);
      address poolUSDC3000 = uniswapFactory.getPool(token, address(USDC), 3000);

      bool poolExist = poolNative3000 != address(0) ||
        poolNative500 != address(0) ||
        poolUSDC3000 != address(0) ||
        poolUSDC500 != address(0);

      if (isTokenNew[i] && poolExist) {
        EnumerableSetUpgradeable.add(tokens, token);
      }

      uint256 amountReceived = balance - tokenBalances[i];

      if (!poolExist) {
        IERC20(token).transfer(msg.sender, amountReceived);
        return;
      }

      if (balance > tokenBalances[i]) {
        uint256 fee = (amountReceived * _BPS_FEE) / _BPS_BASE;
        IERC20(tokensReturn[i]).transfer(getTreasury(), fee);
      }
    }
  }

  /**
   * @dev Liquidates the specified token by swapping it for USDC.
   * @param token The address of the token to be liquidated.
   * @notice The contract must have sufficient approval to spend the specified token.
   * @notice If a pool exists for the token and USDC on Uniswap, a direct swap is performed.
   * @notice If no pool exists, a multi-hop swap is performed through the WNATIVE token.
   * @notice If the swap fails, the `burn` function should be called to handle the failed swap.
   */
  function liquidate(address token) public {
    uint256 totalERC20Balance = IERC20(token).balanceOf(address(this));
    address pool = uniswapFactory.getPool(token, address(USDC), 3000);
    secureApproval(token, address(uniswapRouter), totalERC20Balance);
    bool haveBalance = totalERC20Balance > 0;
    if (pool != address(0) && haveBalance) {
      uint256 singleSwapResult = _singleSwap(token, address(USDC), totalERC20Balance, address(this));
      require(singleSwapResult > 0, 'Swap Failed, Try Burn()');
    } else if (pool == address(0) && haveBalance) {
      uint256 amountOutHop = _multiHopSwap(token, address(WNATIVE), address(USDC), totalERC20Balance, address(this));
      require(amountOutHop > 0, 'Swap Failed, Try Burn()');
    }
  }

  /**
   * @dev Liquidates all tokens in the contract.
   * This function iterates through all the tokens in the contract and calls the `liquidate` function for each token.
   * Can only be called by the contract owner.
   */
  function liquidateAll() public nonReentrant {
    uint256 length = tokens.length();
    for (uint256 i = 0; i < length; i++) {
      address token = tokens.at(i);
      liquidate(token);
    }
  }

  /**
   * @dev Burns a specified amount of BAL tokens from the caller's balance.
   * @param burnAmount The amount of BAL tokens to burn.
   * @notice This function requires the caller to have a balance of at least `burnAmount` BAL tokens.
   * @notice The function also checks the USDC balance before burning the tokens.
   * @notice After burning the tokens, the function transfers a proportional share of each ERC20 token held by the contract to the caller.
   * @notice The share is calculated based on the total supply of BAL tokens, the balance of each ERC20 token, and the decimals of each token.
   * @notice Finally, the function emits a `Burn` event with the caller's address and the amount of tokens burned.
   */
  function burnERC20(uint256 burnAmount) external nonReentrant {
    require(balanceOf(msg.sender) >= burnAmount, 'Insufficient BAL');
    _checkUSDC(burnAmount);

    for (uint256 i; i < tokens.length(); i++) {
      address token = tokens.at(i);
      uint256 totalBaluni = totalSupply();
      uint256 totalERC20Balance = IERC20(token).balanceOf(address(this));

      if (totalERC20Balance == 0 || token == address(this)) continue;

      uint256 decimals = IERC20Metadata(token).decimals();
      uint256 share = _calculateERC20Share(totalBaluni, totalERC20Balance, burnAmount, decimals);
      uint256 amountAfterFee = _calculateNetAmountAfterFee(share);
      IERC20(token).transfer(msg.sender, amountAfterFee);
      IERC20(token).transfer(getTreasury(), share - amountAfterFee);
    }
    _burn(msg.sender, burnAmount);
    emit Burn(msg.sender, burnAmount);
  }

  /**
   * @dev Burns a specified amount of BAL tokens and performs token swaps on multiple tokens.
   * @param burnAmount The amount of BAL tokens to burn.
   */
  function burnUSDC(uint256 burnAmount) public nonReentrant {
    require(burnAmount > 0, 'Insufficient BAL');
    _checkUSDC(burnAmount);

    for (uint256 i; i < tokens.length(); i++) {
      address token = tokens.at(i);
      uint256 totalBaluni = totalSupply();
      uint256 totalERC20Balance = IERC20(token).balanceOf(address(this));

      if (totalERC20Balance > 0 == false) continue;

      if (token == address(this)) continue;

      uint256 decimals = IERC20Metadata(token).decimals();
      uint256 burnAmountToken = _calculateERC20Share(totalBaluni, totalERC20Balance, burnAmount, decimals);

      if (token == address(USDC)) {
        IERC20(USDC).transfer(msg.sender, burnAmountToken);
        continue;
      }

      address pool = uniswapFactory.getPool(token, address(USDC), 3000);
      secureApproval(token, address(uniswapRouter), burnAmountToken);

      if (pool != address(0)) {
        uint256 amountOut = _singleSwap(token, address(USDC), burnAmountToken, address(this));
        uint256 amountAfterFee = _calculateNetAmountAfterFee(amountOut);
        IERC20(address(USDC)).transfer(msg.sender, amountAfterFee);
        IERC20(address(USDC)).transfer(getTreasury(), amountOut - amountAfterFee);
        require(amountOut > 0, 'Swap Failed, Try Burn()');
      } else {
        uint256 amountOutHop = _multiHopSwap(token, address(WNATIVE), address(USDC), burnAmountToken, msg.sender);
        uint256 amountAfterFee = _calculateNetAmountAfterFee(amountOutHop);
        IERC20(address(USDC)).transfer(msg.sender, amountAfterFee);
        IERC20(address(USDC)).transfer(getTreasury(), amountOutHop - amountAfterFee);
        require(amountOutHop > 0, 'Swap Failed, Try Burn()');
      }
    }
    _burn(msg.sender, burnAmount);
    emit Burn(msg.sender, burnAmount);
  }

  /**
   * @dev Retrieves the agent address associated with a user.
   * @param _user The user's address.
   * @return The agent address.
   */
  function getAgentAddress(address _user) external view returns (address) {
    return agentFactory.getAgentAddress(_user);
  }

  /**
   * @dev Mints a specified amount of BALUNI tokens in exchange for USDC.
   * @param balAmountToMint The amount of BALUNI tokens to mint.
   */
  function mintWithUSDC(uint256 balAmountToMint) public nonReentrant {
    uint256 totalUSDValuation = _totalValuation();
    uint256 totalBalSupply = totalSupply();
    uint256 usdcRequired = (balAmountToMint * totalUSDValuation) / totalBalSupply;
    USDC.transferFrom(msg.sender, address(this), usdcRequired / 1e12);
    uint256 balance = IERC20(USDC).balanceOf(msg.sender);
    uint256 allowed = USDC.allowance(msg.sender, address(this));
    require(totalBalSupply > 0, 'Total BALUNI supply cannot be zero');
    require(balance >= usdcRequired / 1e12, 'USDC balance is insufficient');
    require(allowed >= usdcRequired / 1e12, 'Check the token allowance');

    _mint(msg.sender, balAmountToMint);
    emit Mint(msg.sender, balAmountToMint);

    uint256 fee = ((usdcRequired / 1e12) * _BPS_FEE) / _BPS_BASE;
    IERC20(address(USDC)).transfer(getTreasury(), fee);
  }

  /**
   * @dev Calls the `rebalance` function of the `rebalancer` contract.
   * @param assets An array of addresses representing the assets to rebalance.
   * @param weights An array of uint256 values representing the weights of the assets.
   * @param sender The address of the sender.
   * @param receiver The address of the receiver.
   * @param limit The maximum number of assets to rebalance.
   */
  function callRebalance(
    address[] calldata assets,
    uint256[] calldata weights,
    address sender,
    address receiver,
    uint256 limit,
    address baseAsset
  ) external {
    rebalancer.rebalance(assets, weights, sender, receiver, limit, baseAsset);
  }

  /**
   * @dev Calculates the amount of USDC required to mint a given amount of BAL tokens.
   * @param balAmountToMint The amount of BAL tokens to be minted.
   * @return The amount of USDC required to mint the specified amount of BAL tokens.
   */
  function requiredUSDCtoMint(uint256 balAmountToMint) public view returns (uint256) {
    uint256 totalUSDValuation = _totalValuation();
    uint256 totalBalSupply = totalSupply();
    uint256 usdcRequired = (balAmountToMint * totalUSDValuation) / totalBalSupply;
    return usdcRequired / 1e12;
  }

  /**
   * @dev Calculates the token share based on the total Baluni supply, total ERC20 balance, Baluni amount, and token decimals.
   * @param totalBaluni The total supply of Baluni tokens.
   * @param totalERC20Balance The total balance of the ERC20 token.
   * @param baluniAmount The amount of Baluni tokens.
   * @param tokenDecimals The number of decimals for the ERC20 token.
   * @return The calculated token share.
   */
  function calculateTokenShare(
    uint256 totalBaluni,
    uint256 totalERC20Balance,
    uint256 baluniAmount,
    uint256 tokenDecimals
  ) external pure returns (uint256) {
    return _calculateERC20Share(totalBaluni, totalERC20Balance, baluniAmount, tokenDecimals);
  }

  /**
   * @dev Calculates the valuation of a given amount of a specific ERC20 token.
   * @param amount The amount of the ERC20 token.
   * @param token The address of the ERC20 token.
   * @return The calculated valuation of the ERC20 token.
   */
  function tokenValuation(uint256 amount, address token) external view returns (uint256) {
    return _calculateERC20Valuation(amount, token);
  }

  /**
   * @dev Returns the total valuation of the Baluni ecosystem.
   * @return The total valuation of the Baluni ecosystem.
   */
  function totalValuation() external view returns (uint256) {
    return _totalValuation();
  }

  /**
   * @dev Calculates the value of a given amount of Baluni tokens in USDC.
   * @param amount The amount of Baluni tokens.
   * @return The calculated value of the Baluni tokens in USDC.
   */
  function getUSDCShareValue(uint256 amount) external view returns (uint256) {
    return _calculateBaluniToUSDC(amount);
  }

  /**
   * @dev Fetches the market prices of BALUNI tokens.
   * @return The unit price and market price of BALUNI tokens.
   */
  function fetchMarketPrices() external view returns (uint256, uint256) {
    uint256 unitPrice = marketOracle._unitPriceBALUNI();
    uint256 marketPrice = marketOracle._priceBALUNI() * 1e12;
    return (unitPrice, marketPrice);
  }

  /**
   * @dev Ensures that the contract has the necessary approval for a token to be spent by a spender.
   * If the current allowance is not equal to the desired amount, it updates the allowance accordingly.
   * @param token The address of the token to be approved.
   * @param spender The address of the spender.
   * @param amount The desired allowance amount.
   * @notice This function is internal and should not be called directly.
   */
  function secureApproval(address token, address spender, uint256 amount) internal {
    IERC20 _token = IERC20(token);
    uint256 currentAllowance = _token.allowance(address(this), spender);

    if (currentAllowance < amount) {
      _token.approve(spender, 0);
      _token.approve(spender, amount);
    }
  }

  /**
   * @dev Calculates the valuation of an ERC20 token based on the amount and token address.
   * @param amount The amount of the token.
   * @param token The address of the token.
   * @return valuation The valuation of the token.
   */
  function _calculateERC20Valuation(uint256 amount, address token) internal view returns (uint256 valuation) {
    uint256 rate;
    uint8 tokenDecimal = IERC20Metadata(token).decimals();
    uint8 usdcDecimal = IERC20Metadata(address(USDC)).decimals();

    if (token == address(USDC)) return amount * 1e12;

    try I1inchSpotAgg(oracle).getRate(IERC20(token), IERC20(USDC), false) returns (uint256 _rate) {
      rate = _rate;
    } catch {
      return 0;
    }

    if (tokenDecimal == usdcDecimal) return ((amount * 1e12) * (rate)) / 1e18;

    uint256 factor = (10 ** (tokenDecimal - usdcDecimal));

    if (tokenDecimal < 18) return ((amount * factor) * (rate * factor)) / 1e18;

    return ((amount) * (rate * factor)) / 1e18;
  }

  /**
   * @dev Calculates the equivalent amount of USDC tokens for a given amount of Baluni tokens.
   * @param amount The amount of Baluni tokens to convert.
   * @return shareUSDC The equivalent amount of USDC tokens.
   *
   * Requirements:
   * - The total supply of Baluni tokens must be greater than zero.
   */
  function _calculateBaluniToUSDC(uint256 amount) internal view returns (uint256 shareUSDC) {
    uint256 totalBaluni = totalSupply();
    require(totalBaluni > 0, 'Total supply cannot be zero');
    uint256 totalUSDC = _totalValuation();
    shareUSDC = (amount * totalUSDC) / totalBaluni;
  }

  /**
   * @dev Calculates the ERC20 share based on the total Baluni supply, total ERC20 balance,
   * Baluni amount, and token decimals.
   * @param totalBaluni The total supply of Baluni tokens.
   * @param totalERC20Balance The total balance of the ERC20 token.
   * @param baluniAmount The amount of Baluni tokens.
   * @param tokenDecimals The number of decimals for the ERC20 token.
   * @return The calculated ERC20 share.
   */
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

  /**
   * @dev Calculates the total valuation of the contract by summing up the valuation of each token held.
   * @return The total valuation of the contract.
   */
  function _totalValuation() internal view returns (uint256) {
    uint256 _totalV;

    for (uint256 i; i < tokens.length(); i++) {
      address token = tokens.at(i);
      uint256 balance = IERC20(token).balanceOf(address(this));
      uint256 tokenBalanceValuation = _calculateERC20Valuation(balance, token);
      _totalV += tokenBalanceValuation;
    }

    return _totalV;
  }

  /**
   * @dev Calculates the net amount after deducting the fee.
   * @param _amount The input amount.
   * @return The net amount after deducting the fee.
   */
  function _calculateNetAmountAfterFee(uint256 _amount) internal view returns (uint256) {
    uint256 amountInWithFee = (_amount * (_BPS_BASE - (_BPS_FEE))) / _BPS_BASE;
    return amountInWithFee;
  }

  /**
   * @dev Internal function to check the USDC balance and total supply before burning tokens.
   * @param amountToBurn The amount of tokens to be burned.
   */
  function _checkUSDC(uint256 amountToBurn) internal view {
    uint256 balance = IERC20(USDC).balanceOf(address(this));
    if (balance >= 0.001 * 1e6 && totalSupply() >= 1) {
      require(amountToBurn >= 0.01 ether, 'Minimum burn amount is 0.01 BALUNI');
    }
  }

  /**
   * @dev Resizes an array to the specified size.
   * @param arr The array to be resized.
   * @param size The new size of the array.
   * @return The resized array.
   */
  function _resize(uint256[] memory arr, uint256 size) internal pure returns (uint256[] memory) {
    uint256[] memory ret = new uint256[](size);
    for (uint256 i; i < size; i++) {
      ret[i] = arr[i];
    }
    return ret;
  }

  /**
   * @dev Returns the version of the contract.
   * @return The version string.
   */
  function getVersion() external view returns (uint64) {
    return _getInitializedVersion();
  }

  function getTokens() external view returns (address[] memory) {
    return tokens.values();
  }
}
