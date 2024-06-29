import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1Registry = await ethers.getContractFactory('BaluniV1Registry')
  await upgrades.prepareUpgrade('', BaluniV1Registry)
  const _registry = await upgrades.upgradeProxy('', BaluniV1Registry, {
    kind: 'uups',
  })
  const instanceRegistry = await _registry?.waitForDeployment()
  console.log('BaluniV1Registry upgraded to:', await instanceRegistry.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
