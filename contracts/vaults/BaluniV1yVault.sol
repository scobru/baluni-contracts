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
import '../interfaces/IBaluniV1yVault.sol';

contract BaluniV1yVault is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ERC20Upgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    IBaluniV1yVault
{
    // The address of the asset accepted by the pool
    address public baseAsset;

    // The address of the Yearn Vault for assetA
    IYearnVault private _yearnVault;

    // The address of the asset to be purchased with interest
    address public quoteAsset;

    // The registry contract used in the BaluniV1 system
    IBaluniV1Registry private _registry;

    uint256 public accumulatedAssetB;

    uint256 public lastDeposit;

    event Buy(address indexed sender, uint256 amount, uint256 interest);

    /**
     * @dev Initializes the BaluniV1Pool contract.
     * @param _assetA The address of the accepted asset.
     * @param _yearnVaultAddress The address of the Yearn Vault for assetA.
     * @param _assetB The address of the asset to be purchased with interest.
     * @param _registryAddress The address of the BaluniV1Registry contract.
     */
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

        baseAsset = _assetA;
        _yearnVault = IYearnVault(_yearnVaultAddress);
        quoteAsset = _assetB;
        _registry = IBaluniV1Registry(_registryAddress);

        require(baseAsset != address(0), 'Invalid assetA address');
        require(address(_yearnVault) != address(0), 'Invalid Yearn Vault address');
        require(quoteAsset != address(0), 'Invalid assetB address');
    }

    /**
     * @dev Internal function to authorize an upgrade to a new implementation contract.
     * @param newImplementation The address of the new implementation contract.
     * @notice This function can only be called by the contract owner.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Deposits assetA into the pool and Yearn Vault.
     * @param amount The amount of assetA to deposit.
     * @param to The address to receive pool tokens.
     */
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

        // scale up amount
        uint256 amountScaled = amountAfter * 10 ** (18 - baseDecimal);
        _mint(to, amountScaled);

        lastDeposit = _yearnVault.convertToAssets(_yearnVault.balanceOf(address(this)));
    }

    /**
     * @dev Withdraws assetA and assetB from the pool and Yearn Vault.
     * @param shares The amount of pool tokens to redeem.
     * @param to The address to receive assetA and assetB.
     */
    function withdraw(uint256 shares, address to) external override nonReentrant whenNotPaused {
        require(shares > 0, 'Shares must be greater than zero');
        require(balanceOf(msg.sender) >= shares, 'Insufficient balance');

        uint8 yearnDecimal = IERC20Metadata(address(_yearnVault)).decimals();
        uint8 quoteDecimal = IERC20Metadata(quoteAsset).decimals();

        uint256 balanceYearnVault = _yearnVault.balanceOf(address(this));
        uint256 quoteBalance = IERC20(quoteAsset).balanceOf(address(this));
        uint256 baseBalance = IERC20(baseAsset).balanceOf(address(this));

        // scale up totalDeposit and accumualteAssetB
        balanceYearnVault *= 10 ** (18 - yearnDecimal);
        quoteBalance *= 10 ** (18 - quoteDecimal);

        uint256 withdrawAmountA = (shares * balanceYearnVault) / totalSupply();
        uint256 withdrawAmountB = (shares * quoteBalance) / totalSupply();

        _burn(msg.sender, shares);

        // scale down totalDeposit and accumualteAssetB
        withdrawAmountA /= 10 ** (18 - yearnDecimal);
        withdrawAmountB /= 10 ** (18 - quoteDecimal);

        _yearnVault.redeem(withdrawAmountA, address(this), address(this));

        uint256 baseBalanceAfter = IERC20(baseAsset).balanceOf(address(this));
        uint256 amountToSend = baseBalanceAfter - baseBalance;

        uint hairCut = _haircut(amountToSend);
        IERC20(baseAsset).transfer(to, amountToSend - hairCut);

        uint hairCut2 = _haircut(hairCut);
        address baluniRouter = _registry.getBaluniRouter();
        address treasury = _registry.getTreasury();
        IERC20(baseAsset).transfer(baluniRouter, hairCut - hairCut2);
        IERC20(baseAsset).transfer(treasury, hairCut2);

        hairCut = _haircut(withdrawAmountB);
        accumulatedAssetB -= withdrawAmountB;
        IERC20(quoteAsset).transfer(to, withdrawAmountB - hairCut);
        hairCut2 = _haircut(hairCut);
        IERC20(baseAsset).transfer(baluniRouter, hairCut - hairCut2);
        IERC20(baseAsset).transfer(treasury, hairCut2);

        lastDeposit = _yearnVault.convertToAssets(_yearnVault.balanceOf(address(this)));
    }

    /**
     * @dev Uses the accumulated interest to purchase assetB.
     */
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

    function buy() external override nonReentrant onlyOwner whenNotPaused {
        _buy();
    }

    /**
     * @dev Checks and processes accumulated interest.
     */
    function _processInterest() internal {
        uint256 totalAssets = _yearnVault.convertToAssets(_yearnVault.balanceOf(address(this)));
        uint256 interest = totalAssets > lastDeposit ? totalAssets - lastDeposit : 0;
        uint8 baseDecimal = IERC20Metadata(baseAsset).decimals();
        uint limit = 1 * 10 ** (baseDecimal - 2);
        if (interest > limit) {
            _buy();
        }
    }

    /**
     * @dev pause pool, restricting certain operations
     */
    function pause() external override onlyOwner {
        _pause();
    }

    /**
     * @dev unpause pool, enabling certain operations
     */
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
        return valuation;
    }

    function unitPrice() external view override returns (uint256) {
        address USDC = _registry.getUSDC();
        uint8 decimals = IERC20Metadata(USDC).decimals();
        uint256 valuationScaledUp = totalValuation() * 10 ** (18 - decimals);
        return (valuationScaledUp / totalSupply()) * 1e18;
    }

    function registry() external view override returns (address) {
        return address(_registry);
    }

    function yearnVault() external view override returns (address) {
        return address(_yearnVault);
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

    /**
     * @dev Returns the amount of interest earned by the vault.
     * @return The amount of interest earned.
     */
    function interestEarned() external view override returns (uint256) {
        uint256 totalAssets = _yearnVault.convertToAssets(_yearnVault.balanceOf(address(this)));
        uint256 interest = totalAssets > lastDeposit ? totalAssets - lastDeposit : 0;
        return interest;
    }
}
