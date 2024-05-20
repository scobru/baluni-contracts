// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;

import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
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
  IERC20Upgradeable public BALUNI;
  IERC20Upgradeable public USDC;
  IBaluniV1Router public baluniRouter;
  address public oracle;

  event PriceUpdated(uint256 priceBALUNI, uint256 priceBALUNIPool, uint256 lastUpdated);

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  function initialize(address _baluni, address _usdc, address _oracle) public initializer {
    __Ownable_init();
    __UUPSUpgradeable_init();
    BALUNI = IERC20Upgradeable(_baluni);
    USDC = IERC20Upgradeable(_usdc);
    baluniRouter = IBaluniV1Router(_baluni);
    oracle = _oracle;
  }

  function setStaticOracle(address _address) external onlyOwner {
    oracle = _address;
  }

  function priceBALUNI() external view returns (uint256) {
    return _priceBALUNI();
  }

  function unitPriceBALUNI() external view returns (uint256) {
    return _unitPriceBALUNI();
  }

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

  function _unitPriceBALUNI() public view returns (uint256) {
    require(address(baluniRouter) != address(0), 'Router address is not set');

    uint256 unitPrice = baluniRouter.getUnitPrice();

    require(unitPrice > 0, 'Invalid unit price from router');

    return unitPrice;
  }
}
