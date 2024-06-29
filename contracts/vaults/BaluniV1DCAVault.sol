// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol';

import '../interfaces/IBaluniV1Registry.sol';
import '../interfaces/IBaluniV1Swapper.sol';
import '../interfaces/IBaluniV1Oracle.sol';
import '../interfaces/IBaluniV1DCAVault.sol';

contract BaluniV1DCAVault is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ERC20Upgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    IBaluniV1DCAVault
{
    address public baseAsset;
    address public quoteAsset;

    IBaluniV1Registry private _registry;
    uint256 public accumulatedAssetB;

    uint256 public lastDeposit;
    uint256 public lastInvestedBlock;
    uint256 public maxPerSwap;
    uint256 public swapDuration;
    uint256 public reinvestDuration;

    mapping(address => bool) public executors;

    event ExecuteTrade(address indexed sender, uint256 amountIn, uint256 amountOut);

    /**
     * @dev Initializes the BaluniV1DCA contract.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     * @param _baseAsset The address of the base asset.
     * @param _quoteAsset The address of the quote asset.
     * @param _registryAddress The address of the registry contract.
     * @param _reinvestDuration The duration between reinvestments.
     */
    function initialize(
        string memory _name,
        string memory _symbol,
        address _baseAsset,
        address _quoteAsset,
        address _registryAddress,
        uint256 _reinvestDuration
    ) external initializer {
        __Ownable_init(msg.sender);
        __ERC20_init(_name, _symbol);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        baseAsset = _baseAsset;
        quoteAsset = _quoteAsset;
        _registry = IBaluniV1Registry(_registryAddress);

        swapDuration = 360 * _reinvestDuration;
        reinvestDuration = _reinvestDuration;
        lastInvestedBlock = block.number;
        maxPerSwap = 10000 * 10 ** ERC20Upgradeable(_baseAsset).decimals();
    }

    function reinitialize(
        string memory _name,
        string memory _symbol,
        address _baseAsset,
        address _quoteAsset,
        address _registryAddress,
        uint256 _reinvestDuration,
        uint64 _version
    ) external reinitializer(_version) {
        __Ownable_init(msg.sender);
        __ERC20_init(_name, _symbol);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        baseAsset = _baseAsset;
        quoteAsset = _quoteAsset;
        _registry = IBaluniV1Registry(_registryAddress);

        swapDuration = 360 * _reinvestDuration;
        reinvestDuration = _reinvestDuration;
        lastInvestedBlock = block.number;
        maxPerSwap = 10000 * 10 ** ERC20Upgradeable(_baseAsset).decimals();
    }

    function changeReinvestDuration(uint256 _reinvestDuration) external onlyOwner {
        reinvestDuration = _reinvestDuration;
        swapDuration = 360 * _reinvestDuration;
    }

    modifier onlyExecutor() {
        require(executors[msg.sender], 'executor: wut?');
        _;
    }

    /**
     * @dev Internal function to authorize an upgrade to a new implementation contract.
     * @param newImplementation The address of the new implementation contract.
     * @notice This function can only be called by the contract owner.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Deposits assetA into the pool.
     * @param amount The amount of assetA to deposit.
     * @param to The address to receive pool tokens.
     */
    function deposit(uint256 amount, address to) external nonReentrant whenNotPaused {
        require(amount > 0, 'Amount must be greater than zero');

        IERC20(baseAsset).transferFrom(msg.sender, address(this), amount);

        address baluniRouter = _registry.getBaluniRouter();
        address treasury = _registry.getTreasury();

        uint hairCut = _haircut(amount);
        uint hairCut2 = _haircut(hairCut);

        IERC20(baseAsset).transfer(baluniRouter, hairCut - hairCut2);
        IERC20(baseAsset).transfer(treasury, hairCut2);

        uint256 amountAfter = amount - hairCut;
        uint8 baseDecimal = IERC20Metadata(baseAsset).decimals();

        // scale up amount
        uint256 amountScaled = amountAfter * 10 ** (18 - baseDecimal);
        _mint(to, amountScaled);

        lastDeposit += amountAfter;
    }

    /**
     * @dev Withdraws assetA and assetB from the pool.
     * @param shares The amount of pool tokens to redeem.
     * @param to The address to receive assetA and assetB.
     */
    function withdraw(uint256 shares, address to) external nonReentrant whenNotPaused {
        require(shares > 0, 'Shares must be greater than zero');
        require(balanceOf(msg.sender) >= shares, 'Insufficient balance');

        uint8 quoteDecimal = IERC20Metadata(quoteAsset).decimals();
        uint256 quoteBalance = IERC20(quoteAsset).balanceOf(address(this));
        uint256 baseBalance = IERC20(baseAsset).balanceOf(address(this));

        // scale up totalDeposit and accumualteAssetB
        quoteBalance *= 10 ** (18 - quoteDecimal);

        uint256 withdrawAmountA = (shares * baseBalance) / totalSupply();
        uint256 withdrawAmountB = (shares * quoteBalance) / totalSupply();

        _burn(msg.sender, shares);

        // scale down totalDeposit and accumualteAssetB
        withdrawAmountB /= 10 ** (18 - quoteDecimal);

        uint256 amountToSend = withdrawAmountA;

        uint hairCut = _haircut(amountToSend);
        IERC20(baseAsset).transfer(to, amountToSend - hairCut);

        uint hairCut2 = _haircut(hairCut);
        address baluniRouter = _registry.getBaluniRouter();
        address treasury = _registry.getTreasury();
        IERC20(baseAsset).transfer(baluniRouter, hairCut - hairCut2);
        IERC20(baseAsset).transfer(treasury, hairCut2);

        hairCut = _haircut(withdrawAmountB);
        IERC20(quoteAsset).transfer(to, withdrawAmountB - hairCut);
        hairCut2 = _haircut(hairCut);
        IERC20(baseAsset).transfer(baluniRouter, hairCut - hairCut2);
        IERC20(baseAsset).transfer(treasury, hairCut2);

        lastDeposit -= amountToSend;
    }

    function systemDeposit() external onlyExecutor nonReentrant whenNotPaused {
        require((block.number - lastInvestedBlock) > reinvestDuration, 'wait till next reinvest cycle');

        uint amtToSwap = getAmountToSwap(); // return 1e18
        require(amtToSwap > 0, 'Nothing to swap');

        IBaluniV1Swapper swapper = IBaluniV1Swapper(_registry.getBaluniSwapper());
        IERC20(baseAsset).approve(address(swapper), amtToSwap);

        uint256 quoteReceived = swapper.singleSwap(baseAsset, quoteAsset, amtToSwap, address(this));
        lastInvestedBlock = block.number;

        emit ExecuteTrade(msg.sender, amtToSwap, quoteReceived);
    }

    function getAmountToSwap() public view returns (uint) {
        uint baseTokenBal = IERC20(baseAsset).balanceOf(address(this));
        uint blockDiff = block.number - lastInvestedBlock;
        uint toSwapQty = (baseTokenBal * blockDiff) / swapDuration;
        return toSwapQty > maxPerSwap ? maxPerSwap : toSwapQty;
    }

    function canSystemDeposit() public view returns (bool) {
        uint amtToSwap = getAmountToSwap();
        return ((block.number - lastInvestedBlock) > reinvestDuration) && (amtToSwap > 0);
    }

    /**
     * @dev pause pool, restricting certain operations
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev unpause pool, enabling certain operations
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    function unitPrice() external view returns (uint256) {
        if (totalSupply() == 0) return 0;

        address USDC = _registry.getUSDC();
        uint8 decimals = IERC20Metadata(USDC).decimals();
        uint256 factor = 10 ** (18 - decimals);
        uint256 valuationScaledUp = totalValuation() * factor;
        uint256 unitPriceScaled = (valuationScaledUp * 1e18) / totalSupply();
        return unitPriceScaled;
    }

    function registry() external view returns (address) {
        return address(_registry);
    }

    function setExecutor(address _wallet, bool _allow) external onlyOwner {
        executors[_wallet] = _allow;
    }

    /**
     * @dev Calculates the fee amount based on the provided amount using the haircut formula.
     * @param amount The amount to calculate the fee for.
     * @return The fee amount.
     */
    function _haircut(uint256 amount) internal view returns (uint256) {
        uint256 _BPS_FEE = _registry.getBPS_FEE();
        uint256 _BPS_BASE = _registry.getBPS_BASE();
        return (amount * _BPS_FEE) / _BPS_BASE;
    }

    function totalValuation() public view returns (uint256) {
        IBaluniV1Oracle oracle = IBaluniV1Oracle(_registry.getBaluniOracle());
        address USDC = _registry.getUSDC();
        uint256 valuation = 0;

        uint baseBalance = IERC20(baseAsset).balanceOf(address(this));
        uint balanceQuote = IERC20(quoteAsset).balanceOf(address(this));

        if (baseBalance == 0 && balanceQuote == 0) return 0;

        valuation += oracle.convert(quoteAsset, USDC, balanceQuote);

        if (baseAsset == USDC) {
            valuation += baseBalance;
        } else {
            valuation += oracle.convert(baseAsset, USDC, baseBalance);
        }

        return valuation;
    }
}
