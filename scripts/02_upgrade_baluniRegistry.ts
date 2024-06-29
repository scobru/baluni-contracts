import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'

async function main() {
  const BaluniV1Registry = await ethers.getContractFactory('BaluniV1Registry')

  const chainId = 137
  const proxyAddress = contracts[chainId].BaluniV1Registry

  await upgrades.prepareUpgrade(proxyAddress, BaluniV1Registry)
  const _registry = await upgrades.upgradeProxy(proxyAddress, BaluniV1Registry, {
    kind: 'uups',
  })
  const instanceRegistry = await _registry?.waitForDeployment()
  console.log('BaluniV1Registry upgraded to:', await instanceRegistry.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
