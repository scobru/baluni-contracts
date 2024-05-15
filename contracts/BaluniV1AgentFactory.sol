// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.25;
/**
 *  __                  __                      __
 * /  |                /  |                    /  |
 * $$ |____    ______  $$ | __    __  _______  $$/
 * $$      \  /      \ $$ |/  |  /  |/       \ /  |
 * $$$$$$$  | $$$$$$  |$$ |$$ |  $$ |$$$$$$$  |$$ |
 * $$ |  $$ | /    $$ |$$ |$$ |  $$ |$$ |  $$ |$$ |
 * $$ |__$$ |/$$$$$$$ |$$ |$$ \__$$ |$$ |  $$ |$$ |
 * $$    $$/ $$    $$ |$$ |$$    $$/ $$ |  $$ |$$ |
 * $$$$$$$/   $$$$$$$/ $$/  $$$$$$/  $$/   $$/ $$/
 *
 *
 *                  ,-""""-.
 *                ,'      _ `.
 *               /       )_)  \
 *              :              :
 *              \              /
 *               \            /
 *                `.        ,'
 *                  `.    ,'
 *                    `.,'
 *                     /\`.   ,-._
 *                         `-'    \__
 *                              .
 *               s                \
 *                                \\
 *                                 \\
 *                                  >\/7
 *                              _.-(6'  \
 *                             (=___._/` \
 *                                  )  \ |
 *                                 /   / |
 *                                /    > /
 *                               j    < _\
 *                           _.-' :      ``.
 *                           \ r=._\        `.
 */
import '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import './BaluniV1Agent.sol';

contract BaluniV1AgentFactory is OwnableUpgradeable, UUPSUpgradeable {
  // L'indirizzo del contratto logico che sarà utilizzato come implementazione per i proxy
  address private implementation;
  address public router;

  mapping(address => BaluniV1Agent) public userAgents;

  event AgentCreated(address user, address agent);

  /**
   * @dev Changes the implementation of the BaluniV1Agent contract.
   * Only the contract owner can call this function.
   * Creates a new instance of BaluniV1Agent and updates the implementation address.
   */
  function changeImplementation() external onlyOwner {
    BaluniV1Agent newAgent = new BaluniV1Agent(address(this));
    implementation = address(newAgent);
  }

    /**
     * @dev Initializes the contract by calling the initializers of the parent contracts.
     */
    function initialize() public initializer {
      __Ownable_init();
      __UUPSUpgradeable_init();

      // Create a new BaluniV1Agent instance and set it as the implementation address
      BaluniV1Agent newAgent = new BaluniV1Agent(address(this));
      implementation = address(newAgent);
    }

    /**
     * @dev Changes the router address.
     * @param _router The new router address.
     */
    function changeRouter(address _router) external onlyOwner {
      router = _router;
    }
  

  /**
   * @dev Internal function to authorize an upgrade to a new implementation contract.
   * @param newImplementation The address of the new implementation contract.
   */
  function _authorizeUpgrade(
    address newImplementation
  ) internal override onlyOwner {}

  /**
   * @dev Internal function to create a new BaluniV1Agent contract instance.
   * @param salt The salt value used for deterministic cloning.
   * @param user The address of the user for whom the agent is being created.
   * @return The address of the newly created BaluniV1Agent contract instance.
   */
  function _createAgent(
    bytes32 salt,
    address user
  ) internal returns (BaluniV1Agent) {
    address clone = ClonesUpgradeable.cloneDeterministic(implementation, salt);
    BaluniV1Agent(clone).initialize(user, router);
    return BaluniV1Agent(clone);
  }

  /**
   * @dev Retrieves the address of the BaluniV1Agent contract associated with a user.
   * @param user The address of the user.
   * @return The address of the BaluniV1Agent contract associated with the user.
   */
  function getAgentAddress(address user) public view returns (address) {
    return address(userAgents[user]);
  }

  /**
   * @dev Returns the address of an existing agent for the given user, or creates a new agent if one doesn't exist.
   * @param user The address of the user.
   * @return The address of the agent.
   */
  function getOrCreateAgent(address user) external returns (address) {
    require(address(this) != address(0), 'Agent factory not set');
    bytes32 salt = keccak256(abi.encodePacked(user));
    if (
      address(userAgents[user]) == address(0) ||
      isContract(address(userAgents[user])) == false
    ) {
      BaluniV1Agent agent = _createAgent(salt, user);
      require(
        isContract(address(agent)),
        'Agent creation failed, not a contract'
      );
      userAgents[user] = agent;
      emit AgentCreated(user, address(agent));
    }
    return address(userAgents[user]);
  }

  /**
   * @dev Checks if the given address is a contract.
   * @param _addr The address to check.
   * @return A boolean indicating whether the address is a contract or not.
   */
  function isContract(address _addr) private view returns (bool) {
    uint32 size;
    assembly {
      size := extcodesize(_addr)
    }
    return size > 0;
  }
}

