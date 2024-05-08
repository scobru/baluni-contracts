# Baluni Contracts

- BaluniRouter.sol
- BaluniStake.sol
- BaluniAgent.sol

The `BaluniRouter` smart contract offers comprehensive decentralized finance (DeFi) functionalities built on Ethereum, leveraging Solidity version 0.8.25. It incorporates ERC-20 standard features, OpenZeppelin's secure libraries, and integrates with Uniswap V3 for advanced token handling capabilities.

## Key Features

### Token Minting and Burning:
- **Minting:** Users can mint new BALUNI tokens by locking USDC as collateral. A `BPS_FEE` is applied to the USDC amount converted, enhancing the protocol's reward pool with the fee collected. The net USDC after the fee is converted into BALUNI tokens.
- **Burning:** Users can reduce the total supply of BALUNI by burning tokens. In return, they receive a proportional share of the ERC-20 tokens held by the contract, based on their burned amount. This can also be directed to receive a share in USDC, providing flexibility in rewards.

### Staking:
BALUNI tokens can be staked directly within the contract. Staking rewards are dynamically managed based on the total staked balance and other contract activities, incentivizing long-term holding and contribution to network stability.

### Liquidation:
The contract facilitates the liquidation of internal assets by converting them into USDC. Initiators of liquidation are rewarded with BALUNI tokens, encouraging active liquidity management and supporting the contract’s economic model.

### Agent System:
The `BaluniAgent` framework allows users to execute delegated tasks, enhancing interaction within the ecosystem through a modular approach that supports expandable functionalities.

### Swap Operations:
Leveraging Uniswap V3’s protocols, the contract performs internal token swaps to manage its liquidity effectively. These operations convert various ERC-20 tokens into either USDC or BALUNI, optimizing liquidity and ensuring efficient asset management.

### Fee Structure:
- **`BPS_FEE`:** A basis points fee applied for the usage of the protocol, particularly during the `execute` function and when minting BALUNI tokens. This fee is deducted from the USDC used for minting or from the transactions processed through `execute`. The collected fees are allocated to the reward pool, directly benefiting the staking participants.

## Technical Specifications

### Security Measures:
The contract includes `ReentrancyGuard` to prevent re-entrancy attacks, a common vulnerability in Ethereum smart contracts involving external calls.

### Flexibility and Efficiency:
Utilizes `EnumerableSet` to manage sets of addresses, which enhances the efficiency of operations such as adding or checking the presence of tokens.

### Real-Time Pricing:
Integrates with an oracle interface (`IOracle`) to fetch real-time rates for accurate valuation of assets during minting, burning, or swapping operations.

## Governance and Administration

### Ownership and Control:
Managed by an owner account, which has exclusive rights to adjust critical parameters like transaction fees or oracle settings, ensuring adaptability to changing market conditions.

## Interactions and Events

### User Interactions:
Users interact with the contract through functions that allow minting, burning, staking, and liquidating tokens directly from their Ethereum wallets using compatible Web3 interfaces.

### Contract Events:
Specific events are emitted for key actions such as minting (`Mint`), burning (`Burn`), and administrative updates (`ChangeBpsFee`, `ChangeLiquidateFee`), facilitating external tracking and auditing of the contract's activities.
