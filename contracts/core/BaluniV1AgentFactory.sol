// Importa la libreria Upgrades di OpenZeppelin
import '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import './BaluniV1Agent.sol';

contract BaluniV1AgentFactory is Initializable, OwnableUpgradeable, UUPSUpgradeable {
  // L'indirizzo del contratto logico che sarà utilizzato come implementazione per i proxy
  address private implementation;
  address public router;

  mapping(address => BaluniV1Agent) public userAgents;

  event AgentCreated(address user, address agent);

  function changeImplementation() external onlyOwner {
    BaluniV1Agent newAgent = new BaluniV1Agent(address(this));
    implementation = address(newAgent);
  }

  function initialize() public initializer {
    __Ownable_init();
    __UUPSUpgradeable_init();

    BaluniV1Agent newAgent = new BaluniV1Agent(address(this));
    implementation = address(newAgent);
  }

  function changeRouter(address _router) external onlyOwner {
    router = _router;
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  function _createAgent(bytes32 salt, address user) internal returns (BaluniV1Agent) {
    address clone = ClonesUpgradeable.cloneDeterministic(implementation, salt);
    BaluniV1Agent(clone).initialize(user, router);
    return BaluniV1Agent(clone);
  }

  function getAgentAddress(address user) public view returns (address) {
    return address(userAgents[user]);
  }

  function getOrCreateAgent(address user) external returns (address) {
    require(address(this) != address(0), 'Agent factory not set');
    bytes32 salt = keccak256(abi.encodePacked(user));
    if (address(userAgents[user]) == address(0) || isContract(address(userAgents[user])) == false) {
      BaluniV1Agent agent = _createAgent(salt, user);
      require(isContract(address(agent)), 'Agent creation failed, not a contract');
      userAgents[user] = agent;
      emit AgentCreated(user, address(agent));
    }
    return address(userAgents[user]);
  }

  function isContract(address _addr) private view returns (bool) {
    uint32 size;
    assembly {
      size := extcodesize(_addr)
    }
    return size > 0;
  }
}
