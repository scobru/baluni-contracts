# Baluni V1 Protocol

## Overview

Baluni V1 is a decentralized finance (DeFi) protocol that offers advanced financial tools and strategies such as dollar-cost averaging (DCA), yield optimization via Yearn Finance, and automated asset rebalancing. The protocol is designed to be modular, scalable, and easily extensible.

## Key Components

### Agents and Factories

- **BaluniV1Agent.sol**: This contract acts as an orchestrator, managing user interactions and executing rebalance operations when accessed via CLI.
- **BaluniV1AgentFactory.sol**: Responsible for creating and deploying new agent instances, facilitating modularity and scalability when accessed via CLI.

### Pools

- **BaluniV1Pool.sol**: These contracts represent standalone products within the protocol, handling specific financial operations independently.
- **BaluniV1PoolPeriphery.sol**: Provides auxiliary functions and extended features for the main pool contracts.

### Vaults

- **BaluniV1DCAVault.sol**: Implements dollar-cost averaging investment strategies, allowing users to invest steadily over time.
- **BaluniV1YearnVault.sol**: Integrates with Yearn Finance to optimize yield farming and maximize returns on deposited assets.

### Registries and Oracle

- **BaluniV1Registry.sol**: Maintains a comprehensive registry of various entities within the protocol.
- **BaluniV1PoolRegistry.sol**: Keeps records of all pools in the protocol.
- **BaluniV1Oracle.sol**: Provides essential data inputs like price feeds for the protocol’s operations.

### Managers

- **BaluniV1Rebalancer.sol**: Manages the rebalancing of assets to maintain desired allocation ratios within the protocol.
- **BaluniV1Swapper.sol**: Facilitates asset swaps within the protocol, ensuring efficient and cost-effective trades.

### Fee Collection

- **BaluniV1Router.sol**: Collects fees generated from the operations of pools, Yearn Vaults, and DCA Vaults, centralizing the fee management within the protocol.

### Mock Contracts

- **MockOracle.sol**, **MockRebalancer.sol**, **MockSwapRouter.sol**, **MockToken.sol**: These contracts are used for testing and simulation purposes to ensure the robustness and reliability of the protocol.

## How It Works

1. **User Interaction**:
   - **CLI**: When accessed via the CLI, users interact with the protocol through agents, which manage their operations and execute their commands.
   - **UI**: When accessed via the UI, users interact with the protocol directly using their addresses.
2. **Standalone Financial Products**:
   - **Pools, Yearn Vaults, and DCA Vaults**: These components operate independently, each managing specific financial strategies and operations.
3. **Fee Management**: Fees generated from pools, Yearn Vaults, and DCA Vaults are sent to the `BaluniV1Router` contract, centralizing fee collection and distribution.
4. **Automated Strategies**: Features like dollar-cost averaging and asset rebalancing are automated to provide users with optimized financial outcomes.
5. **Data Integrity**: The protocol relies on oracle contracts to fetch accurate price feeds and other necessary data inputs.
6. **Vault Management**: All users are free to trigger compound, rebalance, and execute DCA operations within the vaults. There is no centralized manager for these actions.

## Getting Started

To get started with the Baluni V1 protocol, you can clone the repository and deploy the smart contracts on your preferred Ethereum testnet. Make sure to install all dependencies and follow the deployment instructions provided in the repository.

## Contributing

We welcome contributions from the community. Please fork the repository, make your changes, and submit a pull request. Make sure to follow the contribution guidelines.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Deployments

### Polygon

- BaluniV1Registry deployed to: `0x67438aBdBFE5839a39B3AEf8517B4D213aEf1020`
- BaluniV1Swapper deployed to: `0x1af439B890539c7867cD37eB9B428d34Ec344d10`
- BaluniV1Oracle deployed to: `0x8f9C7474F5894E1EB7D3E4a3E9dC8e487282E631`
- BaluniV1Rebalance deployed to: `0x91e3b021502a408339A884ffe5a897d20Bfa7B9B`
- BaluniV1AgentFactory deployed to: `0x9BC11A2c47419a7994EfeD2d355192B79e6b7BFF`
- BaluniV1Router deployed to: `0x605f25330E33044C13cf277ac14e82D93fcd9BFF`
- BaluniV1PoolPeriphery deployed to: `0xC19Fdc9532D8218E486Bd55B205ceAC371bb4dCf`
- BaluniV1PoolRegistry deployed to: `0x36561C90E151bbB68867808E7992145bcB568Ce5`
- BaluniDCAVaultRegistry deployed to: `0x83b5dC651EbD465e1E20218b8bd92fC0041DD43e`
- BaluniV1YearnVaultRegistry deployed to: `0x4e337Ce8EEBCB8Cb5723c3D21458e67274890617`
