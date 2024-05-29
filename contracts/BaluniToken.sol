pragma solidity 0.8.25;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';

contract BaluniToken is ERC20Upgradeable {
    function initialize(string memory name, string memory symbol) public initializer {
        __ERC20_init(name, symbol);
    }
}
