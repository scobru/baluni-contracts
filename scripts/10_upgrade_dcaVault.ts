import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'

async function main() {
  const BaluniV1DCAVault = await ethers.getContractFactory('BaluniV1DCAVault')
  const chainId = 137
  const proxyAddress = contracts[chainId].BaluniDCAVault_USDCxWBTC
  const registryAddress = contracts[chainId].BaluniV1Registry

  // fetch all tokens for chainId in https://tokens.uniswap.org/
  const response = await fetch('https://tokens.uniswap.org/')
  const data = await response.json()
  const tokens = data.tokens

  // filter token when chainId is 137
  const filteredTokens = tokens.filter((token: any) => token.chainId === 137)
  const USDC = filteredTokens.find((token: any) => token.symbol === 'USDC').address
  const WBTC = filteredTokens.find((token: any) => token.symbol === 'WBTC').address

  const baluniDCAVault = await upgrades.upgradeProxy(proxyAddress, BaluniV1DCAVault, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['Baluni Vault: Dca USDCxWBTC', 'BV-DCA-USDCxWBTC', USDC, WBTC, registryAddress, 3600, 2],
    },
  })
  await baluniDCAVault?.waitForDeployment()
  console.log('BaluniV1DCAVault upgraded to:', baluniDCAVault.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
