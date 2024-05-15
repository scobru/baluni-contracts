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
import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';

import './interfaces/IOracle.sol';
import './interfaces/IBaluniV1AgentFactory.sol';
import './interfaces/IBaluniV1Agent.sol';

contract BaluniV1Router is
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
  EnumerableSetUpgradeable.AddressSet private tokens;
  IERC20Upgradeable private USDC;
  IERC20MetadataUpgradeable private WNATIVE;
  IOracle private oracle;
  ISwapRouter private uniswapRouter;
  IUniswapV3Factory private uniswapFactory;
  IBaluniV1AgentFactory public agentFactory;

  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

  event Execute(
    address user,
    IBaluniV1Agent.Call[] calls,
    address[] tokensReturn
  );
  event Burn(address user, uint256 value);
  event Mint(address user, uint256 value);
  event ChangeBpsFee(uint256 newFee);
  event ChangeRewardPool(address pool);

  /**
   * @dev Initializes the BaluniV1Router contract.
   * It sets the initial values for various variables and mints 1 ether to the contract's address.
   * It also sets the USDC token address, WNATIVE token address, oracle address, Uniswap router address, and Uniswap factory address.
   * Finally, it adds the USDC token address to the tokens set.
   */
  function initialize(
    address _usdc,
    address _wnative,
    address _oracle,
    address _uniRouter,
    address _uniFactory
  ) public initializer {
    __ERC20_init('Baluni', 'BALUNI');
    __Ownable_init();
    __ReentrancyGuard_init();
    __UUPSUpgradeable_init();
    _mint(address(this), 1 ether);

    _MAX_BPS_FEE = 500;
    _BPS_FEE = 30; // 0.3%.
    _BPS_BASE = 10000;
    USDC = IERC20Upgradeable(_usdc);
    WNATIVE = IERC20MetadataUpgradeable(_wnative);
    oracle = IOracle(_oracle); // 1inch Spot Aggregator
    uniswapRouter = ISwapRouter(_uniRouter);
    uniswapFactory = IUniswapV3Factory(_uniFactory);
    EnumerableSetUpgradeable.add(tokens, address(USDC));
  }

  function getTreasury() public view returns (address) {
    return owner();
  }

  /**
   * @dev Internal function to authorize an upgrade to a new implementation contract.
   * @param newImplementation The address of the new implementation contract.
   * @notice This function can only be called by the contract owner.
   */
  function _authorizeUpgrade(
    address newImplementation
  ) internal override onlyOwner {}

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
  function getUnitPrice() public view returns (uint256) {
    return _calculateBaluniToUSDC(1e18);
  }

  /**
   * @dev Returns an array of all listed tokens.
   * @return An array of all listed tokens.
   */
  function listAllTokens() external view returns (address[] memory) {
    return tokens.values();
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
  function execute(
    IBaluniV1Agent.Call[] memory calls,
    address[] memory tokensReturn
  ) external nonReentrant {
    require(address(agentFactory) != address(0), 'Agent factory not set');
    address agent = agentFactory.getOrCreateAgent(msg.sender);
    bool[] memory isTokenNew = new bool[](tokensReturn.length);
    uint256[] memory tokenBalances = new uint256[](tokensReturn.length);

    for (uint256 i = 0; i < tokensReturn.length; i++) {
      isTokenNew[i] = !EnumerableSetUpgradeable.contains(
        tokens,
        tokensReturn[i]
      );
      tokenBalances[i] = IERC20Upgradeable(tokensReturn[i]).balanceOf(
        address(this)
      );
    }

    IBaluniV1Agent(agent).execute(calls, tokensReturn);

    for (uint256 i = 0; i < tokensReturn.length; i++) {
      address token = tokensReturn[i];
      uint256 balance = IERC20Upgradeable(token).balanceOf(address(this));
      address poolNative3000 = uniswapFactory.getPool(
        token,
        address(WNATIVE),
        3000
      );
      address poolNative500 = uniswapFactory.getPool(
        token,
        address(WNATIVE),
        500
      );
      bool poolExist = poolNative3000 != address(0) ||
        poolNative500 != address(0);

      if (isTokenNew[i] && poolExist) {
        EnumerableSetUpgradeable.add(tokens, token);
      }

      if (!poolExist) {
        IERC20Upgradeable(token).transfer(msg.sender, balance);
      }

      if (balance > tokenBalances[i]) {
        uint256 amountReceived = balance - tokenBalances[i];
        uint256 fee = (amountReceived * _BPS_FEE) / _BPS_BASE;
        IERC20Upgradeable(tokensReturn[i]).transfer(getTreasury(), fee);
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
  function liquidate(address token) external nonReentrant {
    uint256 totalERC20Balance = IERC20Upgradeable(token).balanceOf(
      address(this)
    );
    address pool = uniswapFactory.getPool(token, address(USDC), 3000);
    secureApproval(token, address(uniswapRouter), totalERC20Balance);
    if (pool != address(0)) {
      uint256 singleSwapResult = _singleSwap(
        token,
        address(USDC),
        totalERC20Balance,
        address(this)
      );
      require(singleSwapResult > 0, 'Swap Failed, Try Burn()');
    } else {
      uint256 amountOutHop = _multiHopSwap(
        token,
        address(WNATIVE),
        address(USDC),
        totalERC20Balance,
        address(this)
      );
      require(amountOutHop > 0, 'Swap Failed, Try Burn()');
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
      uint256 totalERC20Balance = IERC20Upgradeable(token).balanceOf(
        address(this)
      );

      if (totalERC20Balance == 0 || token == address(this)) continue;

      uint256 decimals = IERC20MetadataUpgradeable(token).decimals();
      uint256 share = _calculateERC20Share(
        totalBaluni,
        totalERC20Balance,
        burnAmount,
        decimals
      );
      uint256 amountAfterFee = _calculateNetAmountAfterFee(share);
      IERC20Upgradeable(token).transfer(msg.sender, amountAfterFee);
      IERC20Upgradeable(token).transfer(getTreasury(), share - amountAfterFee);
    }
    _burn(msg.sender, burnAmount);
    emit Burn(msg.sender, burnAmount);
  }

  /**
   * @dev Burns a specified amount of BAL tokens and performs token swaps on multiple tokens.
   * @param burnAmount The amount of BAL tokens to burn.
   */
  function burnUSDC(uint256 burnAmount) external nonReentrant {
    require(burnAmount > 0, 'Insufficient BAL');
    _checkUSDC(burnAmount);

    for (uint256 i; i < tokens.length(); i++) {
      address token = tokens.at(i);
      uint256 totalBaluni = totalSupply();
      uint256 totalERC20Balance = IERC20Upgradeable(token).balanceOf(
        address(this)
      );

      if (totalERC20Balance > 0 == false) continue;

      if (token == address(this)) continue;

      uint256 decimals = IERC20MetadataUpgradeable(token).decimals();
      uint256 burnAmountToken = _calculateERC20Share(
        totalBaluni,
        totalERC20Balance,
        burnAmount,
        decimals
      );

      if (token == address(USDC)) {
        IERC20Upgradeable(USDC).transfer(msg.sender, burnAmountToken);
        continue;
      }

      address pool = uniswapFactory.getPool(token, address(USDC), 3000);
      secureApproval(token, address(uniswapRouter), burnAmountToken);

      if (pool != address(0)) {
        uint256 amountOut = _singleSwap(
          token,
          address(USDC),
          burnAmountToken,
          address(this)
        );
        uint256 amountAfterFee = _calculateNetAmountAfterFee(amountOut);
        IERC20Upgradeable(address(USDC)).transfer(msg.sender, amountAfterFee);
        IERC20Upgradeable(address(USDC)).transfer(
          getTreasury(),
          amountOut - amountAfterFee
        );
        require(amountOut > 0, 'Swap Failed, Try Burn()');
      } else {
        uint256 amountOutHop = _multiHopSwap(
          token,
          address(WNATIVE),
          address(USDC),
          burnAmountToken,
          msg.sender
        );
        uint256 amountAfterFee = _calculateNetAmountAfterFee(amountOutHop);
        IERC20Upgradeable(address(USDC)).transfer(msg.sender, amountAfterFee);
        IERC20Upgradeable(address(USDC)).transfer(
          getTreasury(),
          amountOutHop - amountAfterFee
        );
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
    uint256 usdcRequired = (balAmountToMint * totalUSDValuation) /
      totalBalSupply;
    USDC.safeTransferFrom(msg.sender, address(this), usdcRequired / 1e12);
    uint256 balance = IERC20Upgradeable(USDC).balanceOf(msg.sender);
    uint256 allowed = USDC.allowance(msg.sender, address(this));
    require(totalBalSupply > 0, 'Total BALUNI supply cannot be zero');
    require(balance >= usdcRequired / 1e12, 'USDC balance is insufficient');
    require(allowed >= usdcRequired / 1e12, 'Check the token allowance');

    _mint(msg.sender, balAmountToMint);
    emit Mint(msg.sender, balAmountToMint);

    uint256 fee = ((usdcRequired / 1e12) * _BPS_FEE) / _BPS_BASE;
    IERC20Upgradeable(address(USDC)).transfer(getTreasury(), fee);
  }

  /**
   * @dev Mints a specified amount of Baluni tokens in exchange for ERC20.
   * @param balAmountToMint The amount of BALUNI tokens to mint.
   * @param asset The address of the asset token.
   * Requirements:
   * - The total BALUNI supply must be greater than zero.
   * - The caller must have a balance of the asset token that is greater than or equal to the required amount.
   * - The caller must have approved the contract to spend the required amount of the asset token.
   * Emits a `Mint` event with the caller's address and the minted amount of BALUNI tokens.
   */
  function mintWithERC20(
    uint256 balAmountToMint,
    address asset
  ) public nonReentrant {
    uint256 totalUSDValuation = _totalValuation();
    uint256 totalBalSupply = totalSupply();
    require(totalBalSupply > 0, 'Total BALUNI supply cannot be zero');

    uint256 usdcRequired = (balAmountToMint * totalUSDValuation) /
      totalBalSupply;
    uint8 decimalA = IERC20MetadataUpgradeable(address(USDC)).decimals();
    uint8 decimalB = IERC20MetadataUpgradeable(asset).decimals();
    uint256 assetRate = oracle.getRate(
      IERC20Upgradeable(USDC),
      IERC20Upgradeable(asset),
      false
    );
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

    uint256 allowed = IERC20Upgradeable(asset).allowance(
      msg.sender,
      address(this)
    );
    require(allowed >= required, 'Check the token allowance');

    IERC20Upgradeable(asset).safeTransferFrom(
      msg.sender,
      address(this),
      required
    );

    _mint(msg.sender, balAmountToMint);
    emit Mint(msg.sender, balAmountToMint);

    uint256 fee = (required * _BPS_FEE) / _BPS_BASE;
    IERC20Upgradeable(asset).transfer(getTreasury(), fee);
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
    return
      _calculateERC20Share(
        totalBaluni,
        totalERC20Balance,
        baluniAmount,
        tokenDecimals
      );
  }

  /**
   * @dev Calculates the valuation of a given amount of a specific ERC20 token.
   * @param amount The amount of the ERC20 token.
   * @param token The address of the ERC20 token.
   * @return The calculated valuation of the ERC20 token.
   */
  function tokenValuation(
    uint256 amount,
    address token
  ) external view returns (uint256) {
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
   * @dev Performs arbitrage based on the market price and unit price.
   * If the market price is lower than the unit price, it buys BALUNI tokens using USDC.
   * If the market price is higher than the unit price, it sells BALUNI tokens for USDC.
   * The function ensures that the necessary balances and approvals are in place before performing the swaps.
   * @notice This function can only be called by external accounts.
   */
  function performArbitrage() external nonReentrant {
    uint256 unitPrice = getUnitPrice();
    uint256 marketPrice = oracle.getRate(
      IERC20Upgradeable(address(this)),
      IERC20Upgradeable(address(USDC)),
      false
    );
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
      uint256 amountOut = _singleSwap(
        address(USDC),
        address(this),
        usdcBalance,
        address(this)
      );
      require(
        amountOut >= amountToBuy,
        'Arbitrage failed: insufficient output amount'
      );
      secureApproval(address(this), address(uniswapRouter), amountOut);
      _singleSwap(address(this), address(USDC), amountOut, address(this));
      require(
        IERC20Upgradeable(USDC).balanceOf(address(this)) > usdcBalance,
        'Arbitrage did not profit'
      );
    } else if (marketPrice > unitPrice) {
      uint256 amountToSell = baluniBalance;
      require(
        amountToSell > 0,
        'Arbitrage failed: insufficient BALUNI balance'
      );
      require(usdcBalance > 0, 'Arbitrage failed: insufficient USDC balance');
      secureApproval(address(this), address(uniswapRouter), amountToSell);
      uint256 amountOutUSDC = _singleSwap(
        address(this),
        address(USDC),
        amountToSell,
        address(this)
      );
      require(
        amountOutUSDC > usdcBalance,
        'Arbitrage failed: insufficient output amount'
      );
      secureApproval(address(USDC), address(uniswapRouter), amountOutUSDC);
      _singleSwap(address(USDC), address(this), amountOutUSDC, address(this));
      require(
        balanceOf(address(this)) > baluniBalance,
        'Arbitrage did not profit'
      );
    }
  }

  /**
   * @dev Ensures that the contract has the necessary approval for a token to be spent by a spender.
   * If the current allowance is not equal to the desired amount, it updates the allowance accordingly.
   * @param token The address of the token to be approved.
   * @param spender The address of the spender.
   * @param amount The desired allowance amount.
   * @notice This function is internal and should not be called directly.
   */
  function secureApproval(
    address token,
    address spender,
    uint256 amount
  ) internal {
    IERC20Upgradeable _token = IERC20Upgradeable(token);
    uint256 currentAllowance = _token.allowance(address(this), spender);

    if (currentAllowance != amount) {
      if (currentAllowance != 0) {
        _token.approve(spender, 0);
      }
      _token.approve(spender, amount);
    }
  }

  /**
   * @dev Calculates the valuation of an ERC20 token based on the amount and token address.
   * @param amount The amount of the token.
   * @param token The address of the token.
   * @return valuation The valuation of the token.
   */
  function _calculateERC20Valuation(
    uint256 amount,
    address token
  ) internal view returns (uint256 valuation) {
    uint256 rate;
    uint8 tokenDecimal = IERC20MetadataUpgradeable(token).decimals();
    uint8 usdcDecimal = IERC20MetadataUpgradeable(address(USDC)).decimals();

    if (token == address(USDC)) return amount * 1e12;

    try
      IOracle(oracle).getRate(
        IERC20Upgradeable(token),
        IERC20Upgradeable(USDC),
        false
      )
    returns (uint256 _rate) {
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
  function _calculateBaluniToUSDC(
    uint256 amount
  ) internal view returns (uint256 shareUSDC) {
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
   * @dev Executes a single swap on Uniswap.
   * @param token0 The address of the input token.
   * @param token1 The address of the output token.
   * @param tokenBalance The amount of input token to be swapped.
   * @param receiver The address that will receive the swapped tokens.
   * @return amountOut The amount of output tokens received.
   */
  function _singleSwap(
    address token0,
    address token1,
    uint256 tokenBalance,
    address receiver
  ) private returns (uint256 amountOut) {
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
      .ExactInputSingleParams({
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

  /**
   * @dev Executes a multi-hop swap using the Uniswap router.
   * @param token0 The address of the first token in the swap path.
   * @param token1 The address of the second token in the swap path.
   * @param token2 The address of the third token in the swap path.
   * @param tokenBalance The amount of tokens to be swapped.
   * @param receiver The address that will receive the swapped tokens.
   * @return amountOut The amount of tokens received after the swap.
   */
  function _multiHopSwap(
    address token0,
    address token1,
    address token2,
    uint256 tokenBalance,
    address receiver
  ) private returns (uint256 amountOut) {
    ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
      path: abi.encodePacked(
        token0,
        uint24(3000),
        token1,
        uint24(3000),
        token2
      ),
      recipient: address(receiver),
      deadline: block.timestamp,
      amountIn: tokenBalance,
      amountOutMinimum: 0
    });
    return uniswapRouter.exactInput(params);
  }

  /**
   * @dev Calculates the total valuation of the contract by summing up the valuation of each token held.
   * @return The total valuation of the contract.
   */
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

  /**
   * @dev Calculates the net amount after deducting the fee.
   * @param _amount The input amount.
   * @return The net amount after deducting the fee.
   */
  function _calculateNetAmountAfterFee(
    uint256 _amount
  ) internal view returns (uint256) {
    uint256 amountInWithFee = (_amount * (_BPS_BASE - (_BPS_FEE))) / _BPS_BASE;
    return amountInWithFee;
  }

  /**
   * @dev Internal function to check the USDC balance and total supply before burning tokens.
   * @param amountToBurn The amount of tokens to be burned.
   */
  function _checkUSDC(uint256 amountToBurn) internal view {
    uint256 balance = IERC20Upgradeable(USDC).balanceOf(address(this));
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
  function _resize(
    uint256[] memory arr,
    uint256 size
  ) internal pure returns (uint256[] memory) {
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
  function getVersion() external pure returns (string memory) {
    return 'v1.0.1';
  }
}
