import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1yVault = await ethers.getContractFactory('BaluniV1YearnVault')
  const baluniVault = await upgrades.upgradeProxy('', BaluniV1yVault, {
    kind: 'uups',
  })
  await baluniVault?.waitForDeployment()
  console.log('BaluniV1YearnVault upgraded to:', baluniVault.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
