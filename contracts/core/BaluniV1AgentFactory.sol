// Importa la libreria Upgrades di OpenZeppelin
import '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import './BaluniV1Agent.sol';

contract BaluniV1AgentFactory is Initializable, OwnableUpgradeable, UUPSUpgradeable {
  // L'indirizzo del contratto logico che sarà utilizzato come implementazione per i proxy
  address private implementation;

  mapping(address => BaluniV1Agent) public userAgents;

  event AgentCreated(address user, address agent);

  function changeImplementation() external onlyOwner {
    // Deploya un nuovo contratto BaluniV1Agent
    BaluniV1Agent newAgent = new BaluniV1Agent();

    // Aggiorna l'indirizzo di implementation con l'indirizzo del nuovo contratto
    implementation = address(newAgent);
  }

  function initialize() public initializer {
    __Ownable_init();
    __UUPSUpgradeable_init();

    // Deploya un'istanza del contratto BaluniV1Agent
    BaluniV1Agent agent = new BaluniV1Agent();

    // Assegna l'indirizzo del contratto deployato a implementation
    implementation = address(agent);
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  function _createAgent(bytes32 salt, address user, address router) internal returns (BaluniV1Agent) {
    // Crea un clone del contratto di implementazione
    address clone = ClonesUpgradeable.cloneDeterministic(implementation, salt);

    // Inizializza il contratto clonato
    BaluniV1Agent(clone).initialize(user, router);

    return BaluniV1Agent(clone);
  }

  // function getOrCreateAgent(address user) private returns (BaluniV1Agent) {
  //   bytes32 salt = keccak256(abi.encodePacked(user));
  //   if (address(userAgents[user]) == address(0)) {
  //     BaluniV1Agent agent = new BaluniV1Agent{salt: salt}(user, address(this));
  //     require(isContract(address(agent)), 'Agent creation failed, not a contract');
  //     userAgents[user] = agent;
  //     emit AgentCreated(user, address(agent));
  //   }
  //   return userAgents[user];
  // }

  function getAgentAddress(address _user) public view returns (address) {
    bytes32 salt = keccak256(abi.encodePacked(_user));
    bytes memory bytecode = getBytecode(_user);
    bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)));
    return address(uint160(uint256(hash)));
  }

  function getOrCreateAgent(address user) external returns (address) {
    require(address(this) != address(0), 'Agent factory not set');
    bytes32 salt = keccak256(abi.encodePacked(user));
    if (address(userAgents[user]) == address(0)) {
      BaluniV1Agent agent = _createAgent(salt, user, address(this));
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

  function getBytecode(address _owner) internal view returns (bytes memory) {
    require(_owner != address(0), 'Owner address cannot be zero.');
    bytes memory bytecode = type(BaluniV1Agent).creationCode;
    return abi.encodePacked(bytecode, abi.encode(_owner, address(this)));
  }
}
