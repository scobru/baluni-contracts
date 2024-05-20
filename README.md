# Baluni Protocol Overview

Baluni is a decentralized finance (DeFi) protocol that offers an advanced algorithm for rebalancing ERC20 tokens. It provides a mechanism for users to mint and burn Baluni tokens, which are backed by a variety of collateral held within the protocol. The protocol also accumulates fees from various operations, and these fees are deposited into the router contract. Users can receive their share of these accumulated fees by participating in the minting and burning process.

## Core Components

### BaluniV1Router

**Description:** The central contract of the Baluni protocol, `BaluniV1Router` manages token operations and interactions with Uniswap. It handles minting, burning, swapping of tokens, and fee management.

**Key Functions:**
- `initialize()`: Sets up the contract with necessary parameters including USDC and WNATIVE token addresses, oracle, Uniswap router, and factory addresses.
- `mintWithUSDC()`: Allows users to mint Baluni tokens using USDC.
- `mintWithERC20()`: Allows users to mint Baluni tokens using other ERC20 tokens based on their valuation.
- `burnERC20()`: Burns Baluni tokens and retrieves a proportional share of underlying assets from the contract.
- `burnUSDC()`: Burns Baluni tokens, performs token swaps, and retrieves USDC in return.
- `execute()`: Executes a series of calls to a BaluniV1Agent contract and handles token returns.
- `liquidate()`: Liquidates specified tokens by swapping them for USDC.
- `performArbitrage()`: Executes arbitrage based on the market price and unit price of Baluni tokens.

### BaluniV1Rebalancer

**Description:** Manages the rebalancing of assets within the protocol to maintain optimal portfolio allocation. It adjusts the weights of different assets based on predefined criteria.

**Key Functions:**
- `rebalance()`: Rebalances assets according to specified weights.
- `checkRebalance()`: Checks if rebalancing is required based on current asset weights and a specified threshold.

### BaluniV1AgentFactory

**Description:** Creates and manages `BaluniV1Agent` contracts that execute batch calls and token operations on behalf of users.

**Key Functions:**
- `getOrCreateAgent()`: Retrieves or creates an agent contract for a user.
- `getAgentAddress()`: Returns the address of the agent contract associated with a user.

### BaluniV1Agent

**Description:** Executes batch calls and token operations on behalf of the user. It ensures efficient handling of complex transactions.

**Key Functions:**
- `execute()`: Executes a batch of calls and performs token operations.
- `_chargeFees()`: Charges fees for the tokens returned to the user.
- `_returnTokens()`: Returns remaining tokens to the owner after executing the batch operations.

## Key Features

### Minting and Burning Baluni Tokens

- **Minting:** Users can mint Baluni tokens by depositing USDC or other ERC20 tokens into the protocol. The amount of Baluni tokens minted is based on the total valuation of the collateral.
- **Burning:** Users can burn Baluni tokens to receive a proportional share of the collateral held in the protocol, including any accumulated fees.

### Rebalancing Algorithm

The protocol offers an algorithm to automatically rebalance the user's portfolio of ERC20 tokens. This ensures that the portfolio maintains optimal asset allocation according to predefined weights.

### Fee Management and Distribution

Fees collected from various operations are deposited into the router contract. To claim their share of these fees, users need to mint Baluni tokens and then burn them. The protocol distributes the fees proportionally based on the amount of Baluni tokens burned.

## Process to Receive Protocol Fees

1. **Minting Baluni Tokens:**
   - Users mint Baluni tokens by depositing USDC or other ERC20 tokens into the `BaluniV1Router` contract.
   - The protocol calculates the required amount of collateral based on the total valuation and mints the corresponding amount of Baluni tokens.

2. **Burning Baluni Tokens:**
   - Users burn the minted Baluni tokens to receive their share of the accumulated fees.
   - Upon burning, the protocol calculates the user's share of the collateral and any accumulated fees, then transfers these assets back to the user.

By offering an advanced rebalancing algorithm, efficient fee management, and a robust system for minting and burning tokens, the Baluni protocol provides users with a comprehensive toolset for managing their ERC20 token portfolios effectively.


## Deployments

### Polygon 
BaluniV1AgentFactory deployed to: 0x4520c7ec5f1800453aE4b87426ba19048f9a3c86
BaluniV1Router deployed to: 0x631E566f96DAAccfFFC2A1846Bd6D3cfA80D5684
BaluniV1Rebalance deployed to: 0x5FAE73b0f45cd40E5A2a36d06ACc05ba7243899f
BaluniV1tablePool deployed to: 0xE9687D54DA4333924ca82D546B44183228C41241
BaluniV1MarketOracle deployed to: a
