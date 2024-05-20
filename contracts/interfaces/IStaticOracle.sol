pragma solidity 0.8.25;

interface IStaticOracle {
  function quoteSpecificPoolsWithTimePeriod(
    uint128 _baseAmount,
    address _baseToken,
    address _quoteToken,
    address[] calldata _pools,
    uint32 _period
  ) external view returns (uint256 _quoteAmount);
}
