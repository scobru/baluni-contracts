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

contract BaluniV1yVault is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ERC20Upgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    // The address of the asset accepted by the pool
    address public baseAsset;

    // The address of the Yearn Vault for assetA
    IYearnVault public yearnVault;

    // The address of the asset to be purchased with interest
    address public quoteAsset;

    // The registry contract used in the BaluniV1 system
    IBaluniV1Registry public registry;

    uint256 public totalDeposits;

    uint256 public accumulatedAssetB;

    /**
     * @dev Initializes the BaluniV1Pool contract.
     * @param _assetA The address of the accepted asset.
     * @param _yearnVault The address of the Yearn Vault for assetA.
     * @param _assetB The address of the asset to be purchased with interest.
     * @param _registry The address of the BaluniV1Registry contract.
     */
    function initialize(
        string memory _name,
        string memory _symbol,
        address _assetA,
        address _yearnVault,
        address _assetB,
        address _registry
    ) external initializer {
        __Ownable_init(msg.sender);
        __ERC20_init(_name, _symbol);

        baseAsset = _assetA;
        yearnVault = IYearnVault(_yearnVault);
        quoteAsset = _assetB;
        registry = IBaluniV1Registry(_registry);

        require(baseAsset != address(0), 'Invalid assetA address');
        require(address(yearnVault) != address(0), 'Invalid Yearn Vault address');
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
    function deposit(uint256 amount, address to) external nonReentrant whenNotPaused {
        require(amount > 0, 'Amount must be greater than zero');

        _processInterest();

        IERC20(baseAsset).transferFrom(msg.sender, address(this), amount);

        IERC20(baseAsset).approve(address(yearnVault), amount);
        yearnVault.deposit(amount, address(this));

        _mint(to, amount);
        totalDeposits += amount;
    }

    /**
     * @dev Withdraws assetA and assetB from the pool and Yearn Vault.
     * @param shares The amount of pool tokens to redeem.
     * @param to The address to receive assetA and assetB.
     */
    function withdraw(uint256 shares, address to) external nonReentrant whenNotPaused {
        require(shares > 0, 'Shares must be greater than zero');
        require(balanceOf(msg.sender) >= shares, 'Insufficient balance');

        uint256 withdrawAmountA = (shares * totalDeposits) / totalSupply();
        uint256 withdrawAmountB = (shares * accumulatedAssetB) / totalSupply();

        _burn(msg.sender, shares);
        totalDeposits -= withdrawAmountA;
        accumulatedAssetB -= withdrawAmountB;

        uint256 sharesToRedeem = yearnVault.convertToShares(withdrawAmountA);
        yearnVault.redeem(sharesToRedeem, address(this), address(this));
        IERC20(baseAsset).transfer(to, withdrawAmountA);
        IERC20(quoteAsset).transfer(to, withdrawAmountB);
    }

    /**
     * @dev Uses the accumulated interest to purchase assetB.
     */
    function buy() public nonReentrant onlyOwner whenNotPaused {
        uint256 totalAssets = yearnVault.convertToAssets(yearnVault.balanceOf(address(this)));
        uint256 interest = totalAssets > totalDeposits ? totalAssets - totalDeposits : 0;
        require(interest > 0, 'No interest available');

        uint256 sharesToRedeem = yearnVault.previewWithdraw(interest);
        yearnVault.redeem(sharesToRedeem, address(this), address(this));

        IBaluniV1Swapper swapper = IBaluniV1Swapper(registry.getBaluniSwapper());

        IERC20(baseAsset).approve(address(swapper), interest);

        uint256 amountOut = swapper.singleSwap(baseAsset, quoteAsset, interest, address(this));

        accumulatedAssetB += amountOut;
    }

    /**
     * @dev Checks and processes accumulated interest.
     */
    function _processInterest() internal {
        uint256 totalAssets = yearnVault.convertToAssets(yearnVault.balanceOf(address(this)));
        uint256 interest = totalAssets > totalDeposits ? totalAssets - totalDeposits : 0;
        if (interest > 0) {
            buy();
        }
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

    function totalValuation() public view returns (uint256) {
        IBaluniV1Oracle oracle = IBaluniV1Oracle(registry.getBaluniOracle());
        address USDC = registry.getUSDC();
        uint256 valuation = 0;
        uint balanceBase = IERC20(baseAsset).balanceOf(address(this));
        uint yearnBalance = yearnVault.balanceOf(address(this));
        uint yearnBalanceConvert = yearnVault.convertToAssets(yearnBalance);
        uint balanceQuote = IERC20(quoteAsset).balanceOf(address(this));
        valuation += oracle.convert(quoteAsset, baseAsset, yearnBalanceConvert);
        valuation += oracle.convert(quoteAsset, baseAsset, balanceQuote);
        if (baseAsset != USDC) valuation += oracle.convert(baseAsset, USDC, balanceBase);
        valuation += balanceBase;
        return valuation;
    }

    function unitPrice() external view returns (uint256) {
        address USDC = registry.getUSDC();
        uint8 decimals = IERC20Metadata(USDC).decimals();
        uint256 valuationScaledUp = totalValuation() * 10 ** (18 - decimals);
        return (valuationScaledUp / totalSupply()) * 1e18;
    }
}
