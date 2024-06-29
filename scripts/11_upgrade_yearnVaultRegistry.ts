import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1YearnVaultRegistry = await ethers.getContractFactory('BaluniV1YearnVaultRegistry')
  await upgrades.prepareUpgrade('', BaluniV1YearnVaultRegistry)
  const baluniVaultRegistry = await upgrades.upgradeProxy('', BaluniV1YearnVaultRegistry, {
    kind: 'uups',
  })
  await baluniVaultRegistry?.waitForDeployment()
  console.log('BaluniV1YearnVaultRegistry upgraded to:', baluniVaultRegistry.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
