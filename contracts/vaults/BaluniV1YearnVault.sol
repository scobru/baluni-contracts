// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol';

import '../interfaces/IBaluniV1Registry.sol';
import '../interfaces/IYearnVault.sol';
import '../interfaces/IBaluniV1Swapper.sol';
import '../interfaces/IBaluniV1Oracle.sol';
import '../interfaces/IBaluniV1YearnVault.sol';

contract BaluniV1YearnVault is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ERC20Upgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    IBaluniV1YearnVault
{
    address public baseAsset;
    IYearnVault private _yearnVault;
    address public quoteAsset;
    IBaluniV1Registry private _registry;

    uint256 public accumulatedAssetB;
    uint256 public lastDeposit;
    uint256 public allTimeInterest;

    event Buy(address indexed sender, uint256 amount, uint256 interest);

    function initialize(
        string memory _name,
        string memory _symbol,
        address _assetA,
        address _yearnVaultAddress,
        address _assetB,
        address _registryAddress
    ) external initializer {
        __Ownable_init(msg.sender);
        __ERC20_init(_name, _symbol);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        baseAsset = _assetA;
        _yearnVault = IYearnVault(_yearnVaultAddress);
        quoteAsset = _assetB;
        _registry = IBaluniV1Registry(_registryAddress);

        require(baseAsset != address(0), 'Invalid assetA address');
        require(address(_yearnVault) != address(0), 'Invalid Yearn Vault address');
        require(quoteAsset != address(0), 'Invalid assetB address');
    }

    function reinitialize(
        string memory _name,
        string memory _symbol,
        address _assetA,
        address _yearnVaultAddress,
        address _assetB,
        address _registryAddress,
        uint64 _version
    ) external reinitializer(_version) {
        __Ownable_init(msg.sender);
        __ERC20_init(_name, _symbol);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        baseAsset = _assetA;
        _yearnVault = IYearnVault(_yearnVaultAddress);
        quoteAsset = _assetB;
        _registry = IBaluniV1Registry(_registryAddress);

        require(baseAsset != address(0), 'Invalid assetA address');
        require(address(_yearnVault) != address(0), 'Invalid Yearn Vault address');
        require(quoteAsset != address(0), 'Invalid assetB address');
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function deposit(uint256 amount, address to) external override nonReentrant whenNotPaused {
        require(amount > 0, 'Amount must be greater than zero');

        _processInterest();

        IERC20(baseAsset).transferFrom(msg.sender, address(this), amount);

        address baluniRouter = _registry.getBaluniRouter();
        address treasury = _registry.getTreasury();

        uint hairCut = _haircut(amount);
        uint hairCut2 = _haircut(hairCut);

        IERC20(baseAsset).transfer(baluniRouter, hairCut - hairCut2);
        IERC20(baseAsset).transfer(treasury, hairCut2);

        uint256 amountAfter = amount - hairCut;

        IERC20(baseAsset).approve(address(_yearnVault), amountAfter);
        _yearnVault.deposit(amountAfter, address(this));

        uint8 baseDecimal = IERC20Metadata(baseAsset).decimals();
        uint8 yearnDecimal = IERC20Metadata(address(_yearnVault)).decimals();

        if (baseDecimal > yearnDecimal) {
            amountAfter = amountAfter / 10 ** (baseDecimal - yearnDecimal);
        } else {
            amountAfter = amountAfter * 10 ** (yearnDecimal - baseDecimal);
        }

        uint256 amountScaled = amountAfter * 10 ** (18 - yearnDecimal);

        _mint(to, amountScaled);

        lastDeposit = _yearnVault.convertToAssets(_yearnVault.balanceOf(address(this)));

        accumulatedAssetB = IERC20(quoteAsset).balanceOf(address(this));
    }

    function _buy() internal {
        uint256 totalAssets = _yearnVault.convertToAssets(_yearnVault.balanceOf(address(this)));
        uint256 interest = totalAssets > lastDeposit ? totalAssets - lastDeposit : 0;
        require(interest > 0, 'BaluniV1yVault: No interest available');

        uint256 sharesToRedeem = _yearnVault.convertToShares(interest);
        uint256 amountOut = _yearnVault.redeem(sharesToRedeem, address(this), address(this));

        require(amountOut > 0, 'BaluniV1yVault: Redeem Failed');

        IBaluniV1Swapper swapper = IBaluniV1Swapper(_registry.getBaluniSwapper());

        IERC20(baseAsset).approve(address(swapper), amountOut);

        swapper.singleSwap(baseAsset, quoteAsset, amountOut, address(this));

        emit Buy(msg.sender, amountOut, interest);
    }

    function buy() external override nonReentrant whenNotPaused {
        _buy();
    }

    function _processInterest() internal {
        uint256 totalAssets = _yearnVault.convertToAssets(_yearnVault.balanceOf(address(this)));
        uint256 interest = totalAssets > lastDeposit ? totalAssets - lastDeposit : 0;
        uint8 baseDecimal = IERC20Metadata(baseAsset).decimals();
        uint limit = 1 * 10 ** (baseDecimal - 2);
        if (interest > limit) {
            _buy();
        }

        accumulatedAssetB = IERC20(quoteAsset).balanceOf(address(this));
    }

    function pause() external override onlyOwner {
        _pause();
    }

    function unpause() external override onlyOwner {
        _unpause();
    }

    function totalValuation() public view override returns (uint256) {
        IBaluniV1Oracle oracle = IBaluniV1Oracle(_registry.getBaluniOracle());
        address USDC = _registry.getUSDC();
        uint256 valuation = 0;

        uint yearnBalance = _yearnVault.balanceOf(address(this));
        uint yearnBalanceConvert = _yearnVault.convertToAssets(yearnBalance);
        uint balanceQuote = IERC20(quoteAsset).balanceOf(address(this));

        if (baseAsset != USDC) valuation += oracle.convert(baseAsset, USDC, yearnBalanceConvert);
        valuation += oracle.convert(quoteAsset, baseAsset, balanceQuote);
        valuation += yearnBalanceConvert;

        uint256 interest = interestEarned();

        if (baseAsset != USDC) valuation += oracle.convert(baseAsset, USDC, interest);

        valuation += interest;

        return valuation;
    }

    function unitPrice() external view override returns (uint256) {
        if (totalSupply() == 0) return 0;
        address USDC = _registry.getUSDC();
        uint8 decimals = IERC20Metadata(USDC).decimals();
        uint256 factor = 10 ** (18 - decimals);
        uint256 valuationScaledUp = totalValuation() * factor;
        uint256 unitPriceScaled = (valuationScaledUp * 1e18) / totalSupply();
        return unitPriceScaled;
    }

    function registry() external view override returns (address) {
        return address(_registry);
    }

    function yearnVault() external view override returns (address) {
        return address(_yearnVault);
    }

    function _haircut(uint256 amount) internal view returns (uint256) {
        uint256 _BPS_FEE = _registry.getBPS_FEE();
        uint256 _BPS_BASE = _registry.getBPS_BASE();
        return (amount * _BPS_FEE) / _BPS_BASE;
    }

    function interestEarned() public view override returns (uint256) {
        uint256 totalAssets = _yearnVault.convertToAssets(_yearnVault.balanceOf(address(this)));
        uint256 interest = totalAssets > lastDeposit ? totalAssets - lastDeposit : 0;
        return interest;
    }

    function withdraw(uint256 shares, address to) external override nonReentrant whenNotPaused {
        require(shares > 0, 'Shares must be greater than zero');
        require(balanceOf(msg.sender) >= shares, 'Insufficient balance');
        require(totalSupply() > 0, "Total supply cannot be zero");

        uint8 yearnDecimal = IERC20Metadata(address(_yearnVault)).decimals();
        uint8 quoteDecimal = IERC20Metadata(quoteAsset).decimals();
        
        // Ottieni i saldi
        uint256 balanceYearnVault = _yearnVault.balanceOf(address(this));
        uint256 quoteBalance = IERC20(quoteAsset).balanceOf(address(this));
        uint256 baseBalance = IERC20(baseAsset).balanceOf(address(this));

        // Verifica che la moltiplicazione non causi overflow
        require(balanceYearnVault <= type(uint256).max / (10 ** (18 - yearnDecimal)), 
            "YearnVault balance scaling would overflow");
        require(quoteBalance <= type(uint256).max / (10 ** (18 - quoteDecimal)), 
            "Quote balance scaling would overflow");

        // Scala i saldi
        balanceYearnVault *= 10 ** (18 - yearnDecimal);
        quoteBalance *= 10 ** (18 - quoteDecimal);

        // Verifica che shares non causi overflow nella moltiplicazione
        require(shares <= type(uint256).max / balanceYearnVault, "Shares calculation would overflow");
        require(shares <= type(uint256).max / quoteBalance, "Shares calculation would overflow");

        // Calcola gli importi da prelevare
        uint256 withdrawAmountA = (shares * balanceYearnVault) / totalSupply();
        uint256 withdrawAmountB = (shares * quoteBalance) / totalSupply();

        _burn(msg.sender, shares);

        // Riscala gli importi
        withdrawAmountA /= 10 ** (18 - yearnDecimal);
        withdrawAmountB /= 10 ** (18 - quoteDecimal);

        // Verifica che ci siano abbastanza asset nel yearnVault
        require(withdrawAmountA <= _yearnVault.convertToAssets(balanceYearnVault), 
            "Insufficient assets in Yearn Vault");

        _yearnVault.redeem(withdrawAmountA, address(this), address(this));

        uint256 baseBalanceAfter = IERC20(baseAsset).balanceOf(address(this));
        require(baseBalanceAfter >= baseBalance, "Base balance check failed");
        uint256 amountToSend = baseBalanceAfter - baseBalance;
        address receiver = to;

        if (amountToSend > 0) {
            uint256 hairCut = _haircut(amountToSend);
            require(hairCut <= amountToSend, "Haircut exceeds amount");
            
            uint256 amountAfterHaircut = amountToSend - hairCut;
            uint256 hairCut2 = _haircut(hairCut);
            require(hairCut2 <= hairCut, "Secondary haircut exceeds primary haircut");
            
            address baluniRouter = _registry.getBaluniRouter();
            address treasury = _registry.getTreasury();
            
            IERC20(baseAsset).transfer(receiver, amountToSend - hairCut);
            IERC20(baseAsset).transfer(baluniRouter, hairCut - hairCut2);
            IERC20(baseAsset).transfer(treasury, hairCut2);
        }

        if (withdrawAmountB > 0) {
            bool success = _handleWithdrawB(withdrawAmountB, receiver);
            require(success, "Failed to transfer quoteAsset");
        }

        lastDeposit = _yearnVault.convertToAssets(_yearnVault.balanceOf(address(this)));
    }

    function _handleWithdrawB(uint256 withdrawAmountB, address receiver) internal returns (bool) {
        require(withdrawAmountB <= IERC20(quoteAsset).balanceOf(address(this)), 
            "Insufficient quote asset balance");
        
        uint256 hairCut = _haircut(withdrawAmountB);
        require(hairCut <= withdrawAmountB, "Haircut exceeds withdrawal amount");
        
        uint256 amountAfterHaircut = withdrawAmountB - hairCut;
        uint256 hairCut2 = _haircut(hairCut);
        require(hairCut2 <= hairCut, "Secondary haircut exceeds primary haircut");
        
        address baluniRouter = _registry.getBaluniRouter();
        address treasury = _registry.getTreasury();
        
        IERC20(quoteAsset).transfer(receiver, amountAfterHaircut);
        IERC20(quoteAsset).transfer(baluniRouter, hairCut - hairCut2);
        IERC20(quoteAsset).transfer(treasury, hairCut2);
        
        return true;
    }
}
