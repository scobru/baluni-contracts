## Baluni Protocol Overview

Baluni is a decentralized finance (DeFi) protocol that offers an advanced algorithm for rebalancing ERC20 tokens. It provides a mechanism for users to mint and burn Baluni tokens, which are backed by a variety of collateral held within the protocol. The protocol also accumulates fees from various operations, and these fees are deposited into the router contract. Users can receive their share of these accumulated fees by participating in the minting and burning process.

## Core Components

### `BaluniV1Router`

**Description:** The central contract of the Baluni protocol. It manages token operations and interactions with Uniswap, handling minting, burning, swapping of tokens, and fee management.

**Key Functions:**

- `initialize()`: Sets up the contract with necessary parameters.
- `mintWithUSDC()`: Allows users to mint Baluni tokens using USDC.
- `mintWithERC20()`: Allows users to mint Baluni tokens using other ERC20 tokens.
- `burnERC20()`: Burns Baluni tokens and retrieves a proportional share of underlying assets.
- `burnUSDC()`: Burns Baluni tokens, performs token swaps, and retrieves USDC.
- `execute()`: Executes calls to a `BaluniV1Agent` contract.
- `liquidate()`: Liquidates specified tokens for USDC.
- `performArbitrage()`: Executes arbitrage based on market conditions.

### `BaluniV1Rebalancer`

**Description:** Manages the rebalancing of assets within the protocol to maintain optimal portfolio allocation.

**Key Functions:**

- `rebalance()`: Rebalances assets according to specified weights.
- `checkRebalance()`: Checks if rebalancing is required.

### `BaluniV1AgentFactory`

**Description:** Creates and manages `BaluniV1Agent` contracts for executing batch calls and token operations.

**Key Functions:**

- `getOrCreateAgent()`: Retrieves or creates an agent contract for a user.
- `getAgentAddress()`: Returns the address of a user's agent contract.

### `BaluniV1Agent`

**Description:** Executes batch calls and token operations on behalf of users.

**Key Functions:**

- `execute()`: Executes a batch of calls and performs token operations.
- `_chargeFees()`: Charges fees for returned tokens.
- `_returnTokens()`: Returns remaining tokens to the owner.

## Key Features

- **Minting and Burning Baluni Tokens:**  Users can mint Baluni tokens by depositing collateral and burn them to receive a share of the underlying assets and fees.
- **Rebalancing Algorithm:** Automatically rebalances user portfolios for optimal asset allocation.
- **Fee Management and Distribution:**  Collects fees and distributes them to users who burn Baluni tokens.

## Process to Receive Protocol Fees

1. **Mint Baluni Tokens:** Deposit USDC or ERC20 tokens.
2. **Burn Baluni Tokens:** Receive a share of collateral and accumulated fees.

## Additional Contracts

### `BaluniV1PoolFactory`

**Description:** A factory contract responsible for creating and managing `BaluniV1Pool` instances.

**Key Functions:**

- `createPool()`: Creates a new pool for a pair of assets.
- `getAllPools()`: Returns an array of all created pools.
- `getPoolsCount()`: Returns the total number of pools.
- `getPoolAssets()`: Retrieves the assets of a specific pool.
- `getPoolByAssets()`: Retrieves a pool by its asset pair.

### `BaluniV1PoolPeriphery`

**Description:** A periphery contract for interacting with `BaluniV1Pool` contracts, providing user-friendly functions for swapping, adding/removing liquidity, and getting price information.

**Key Functions:**

- `swap()`: Swaps tokens through a pool.
- `addLiquidity()`: Adds liquidity to a pool.
- `removeLiquidity()`: Removes liquidity from a pool.
- `getAmountOut()`: Gets the estimated output amount for a swap.
- `performRebalanceIfNeeded()`: Triggers a rebalance if necessary.

## `BaluniV1Pool` Contract

**Description:** This contract represents a liquidity pool for a pair of ERC20 tokens within the Baluni Protocol. It facilitates the exchange of these tokens, allows users to provide liquidity and earn fees, and enables the rebalancing of pool assets for optimal allocation.

**Key Functions:**

- `swap()`: Allows users to swap one token for another within the pool, charging a fee.
- `getAmountOut()`: Calculates the expected output amount for a given swap.
- `addLiquidity()`: Enables users to add liquidity to the pool in exchange for LP tokens.
- `exit()`: Allows users to withdraw their liquidity from the pool.
- `totalLiquidityInAsset1/2()`: Calculates the total liquidity value in terms of each asset.
- `performRebalanceIfNeeded()`: Triggers rebalancing of pool assets if necessary.
- `getDeviation()`: Calculates the deviation of the current pool asset weights from the target weights.
- `_performRebalanceIfNeeded()`: Internal function to handle the rebalancing process.
- `getReserves()`: Returns the current reserves of both assets in the pool.

**Events:**

- `Swap`: Emitted when a swap occurs.
- `LiquidityAdded`: Emitted when liquidity is added to the pool.
- `LiquidityRemoved`: Emitted when liquidity is removed from the pool.
- `RebalancePerformed`: Emitted when a rebalance operation is executed.

## `BaluniV1MarketOracle` Contract

**Description:** This contract acts as the market oracle for the Baluni Protocol. It determines the price of BALUNI tokens in relation to USDC using an external oracle and Uniswap V3 pool data.

**Key Functions:**

- `initialize()/reinitialize()`: Initializes/reinitializes the contract with BALUNI, USDC, and oracle addresses.
- `setStaticOracle()`: Allows the owner to update the static oracle address.
- `priceBALUNI()`: Returns the price of BALUNI in USDC.
- `unitPriceBALUNI()`: Returns the unit price of BALUNI from the Baluni Router.
- `_priceBALUNI()`: Internal function to fetch the BALUNI price from the oracle.
- `_unitPriceBALUNI()`: Internal function to get the BALUNI unit price from the router.

**Events:**

- `PriceUpdated`: Emitted when the price of BALUNI is updated.

### Deployment Polygon 

BaluniV1AgentFactory deployed to: 0x50953ba8BD92523168a63711DBf534fE4F619d0A
BaluniV1Router deployed to: 0x8DD108DDC24A6b07Bc9191DE5f0337f240c4e0c0
BaluniV1Rebalance deployed to: 0x1CC8A760bb5d714E3290a30044c6f4f4cEc01dac

BaluniV1MarketOracle deployed to: 0x3D22f6bdE20E8647B96d0BAbc21b9BB610FB53A5

BaluniV1PoolFactory deployed to: 0x532D40e35C19912d5C94d6a426Bb58EC9f7D60E2
BaluniV1PoolPeriphery deployed to: 0x31413CE6C213f01f6ffa8c2176feCcB2868B30b3
