import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'

const chainId = 137

async function main() {
  const proxyAddress = contracts[chainId].BaluniPoolStable
  const registryAddress = contracts[chainId].BaluniV1Registry
  const response = await fetch('https://tokens.uniswap.org/')
  const data = await response.json()
  const tokens = data.tokens
  const filteredTokens = tokens.filter((token: any) => token.chainId === 137)
  const USDT = filteredTokens.find((token: any) => token.symbol === 'USDT').address
  const USDC = filteredTokens.find((token: any) => token.symbol === 'USDC').address
  const DAI = filteredTokens.find((token: any) => token.symbol === 'DAI').address
  const USDCE = filteredTokens.find((token: any) => token.symbol === 'USDC.e').address

  const BaluniV1Pool = await ethers.getContractFactory('BaluniV1Pool')
  await upgrades.prepareUpgrade(proxyAddress, BaluniV1Pool)

  const baluniPool = await upgrades.upgradeProxy(proxyAddress, BaluniV1Pool, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: [
        'Baluni Pool: Stable',
        'BP-STBL-USDCxUSDCExUSDTxDAI',
        [USDC, USDCE, USDT, DAI],
        [2500, 2500, 2500, 2500],
        registryAddress,
        2,
      ],
    },
  })

  await baluniPool?.waitForDeployment()
  console.log('BaluniV1Pool upgraded to:', baluniPool.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
