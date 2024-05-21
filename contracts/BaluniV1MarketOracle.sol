// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import './interfaces/IStaticOracle.sol';

interface IBaluniV1Router {
  function getAgentAddress(address _user) external view returns (address);

  function getBpsFee() external view returns (uint256);

  function tokenValuation(uint256 amount, address token) external view returns (uint256);

  function getTreasury() external view returns (address);

  function getUnitPrice() external view returns (uint256);
}

contract BaluniV1MarketOracle is Initializable, OwnableUpgradeable, UUPSUpgradeable {
  IERC20 public BALUNI;
  IERC20 public USDC;
  IBaluniV1Router public baluniRouter;
  address public oracle;

  event PriceUpdated(uint256 priceBALUNI, uint256 priceBALUNIPool, uint256 lastUpdated);

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  /**
   * @dev Initializes the contract with the specified addresses.
   * @param _baluni The address of the BALUNI token contract.
   * @param _usdc The address of the USDC token contract.
   * @param _oracle The address of the oracle contract.
   */
  function initialize(address _baluni, address _usdc, address _oracle) public initializer {
    __Ownable_init(msg.sender);
    __UUPSUpgradeable_init();
    BALUNI = IERC20(_baluni);
    USDC = IERC20(_usdc);
    baluniRouter = IBaluniV1Router(_baluni);
    oracle = _oracle;
  }

  /**
   * @dev Reinitializes the contract with the specified addresses and version.
   * @param _baluni The address of the BALUNI token contract.
   * @param _usdc The address of the USDC token contract.
   * @param _oracle The address of the oracle contract.
   * @param version The version of the contract.
   */
  function reinitialize(address _baluni, address _usdc, address _oracle, uint64 version) public reinitializer(version) {
    __Ownable_init(msg.sender);
    __UUPSUpgradeable_init();
    BALUNI = IERC20(_baluni);
    USDC = IERC20(_usdc);
    baluniRouter = IBaluniV1Router(_baluni);
    oracle = _oracle;
  }

  /**
   * @dev Sets the static oracle address.
   * @param _address The address of the static oracle.
   */
  function setStaticOracle(address _address) external onlyOwner {
    oracle = _address;
  }

  /**
   * @dev Returns the price of BALUNI.
   * @return The price of BALUNI.
   */
  function priceBALUNI() external view returns (uint256) {
    return _priceBALUNI();
  }

  /**
   * @dev Returns the unit price of BALUNI.
   * @return The unit price of BALUNI.
   */
  function unitPriceBALUNI() external view returns (uint256) {
    return _unitPriceBALUNI();
  }

  /**
   * @dev Returns the price of BALUNI token in USDC.
   * @return The price of BALUNI token in USDC.
   */
  function _priceBALUNI() public view returns (uint256) {
    require(oracle != address(0), 'Oracle address is not set');

    address uniswapFactory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address pool = IUniswapV3Factory(uniswapFactory).getPool(address(BALUNI), address(USDC), 3000);

    require(pool != address(0), 'Uniswap V3 pool does not exist');

    address[] memory _pools = new address[](1);
    _pools[0] = pool;

    uint256 price = IStaticOracle(oracle).quoteSpecificPoolsWithTimePeriod(
      uint128(1e18),
      address(BALUNI),
      address(USDC),
      _pools,
      60
    );

    require(price > 0, 'Invalid price from oracle');

    return price;
  }

  /**
   * @dev Returns the unit price of BALUNI token.
   * @return The unit price of BALUNI token.
   */
  function _unitPriceBALUNI() public view returns (uint256) {
    require(address(baluniRouter) != address(0), 'Router address is not set');

    uint256 unitPrice = baluniRouter.getUnitPrice();

    require(unitPrice > 0, 'Invalid unit price from router');

    return unitPrice;
  }
}
