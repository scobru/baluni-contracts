import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1DCAVaultRegistry = await ethers.getContractFactory('BaluniV1DCAVaultRegistry')
  await upgrades.prepareUpgrade('', BaluniV1DCAVaultRegistry)
  const baluniVaultRegistry = await upgrades.upgradeProxy('', BaluniV1DCAVaultRegistry, {
    kind: 'uups',
  })
  await baluniVaultRegistry?.waitForDeployment()
  console.log('BaluniV1YearnVaultRegistry upgraded to:', baluniVaultRegistry.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
