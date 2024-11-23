import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'

const chainId = 137

async function main() {
  const proxyAddress = contracts[chainId].BaluniYearnVault_USDCxWBTC
  const registryAddress = contracts[chainId].BaluniV1Registry
  const response = await fetch('https://tokens.uniswap.org/')
  const data = await response.json()
  const tokens = data.tokens
  const filteredTokens = tokens.filter((token: any) => token.chainId === 137)
  const USDC = filteredTokens.find((token: any) => token.symbol === 'USDC').address
  const WBTC = filteredTokens.find((token: any) => token.symbol === 'WBTC').address
  const BaluniV1YearnVault = await ethers.getContractFactory('BaluniV1YearnVault')
  const yearnVault = '0x34b9421Fe3d52191B64bC32ec1aB764dcBcDbF5e'
  const baluniVault = await upgrades.upgradeProxy(proxyAddress, BaluniV1YearnVault, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['BALUNI YEARN VAULT : USDCxWBTC', 'BYV-USDCxWBTC', USDC, yearnVault, WBTC, registryAddress, 15],
    },
  })
  await baluniVault?.waitForDeployment()
  console.log('BaluniV1YearnVault upgraded to:', baluniVault.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
