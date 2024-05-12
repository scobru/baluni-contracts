pragma solidity 0.8.25;
import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

interface IOracle {
  function getRate(
    IERC20Upgradeable srcToken,
    IERC20Upgradeable dstToken,
    bool useWrappers
  ) external view returns (uint256 weightedRate);
}
