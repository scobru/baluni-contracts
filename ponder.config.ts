import { createConfig } from '@ponder/core'
import { http } from 'viem'

import { BaluniV1RouterABI } from './BaluniV1RouterAbi'

export default createConfig({
  networks: {
    mainnet: {
      chainId: 137,
      transport: http(process.env.PONDER_RPC_URL_1),
    },
  },
  contracts: {
    BaluniV1Router: {
      network: 'mainnet',
      abi: BaluniV1RouterABI as any,
      address: '0xEd1B284de8D6B398B5744F5178E8BE198A4DaF5e', // Replace with the actual contract address
      startBlock: 57651477, // Replace with the actual block number where the contract was deployed
    },
  },
})
