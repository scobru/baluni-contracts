import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1PoolRegistry = await ethers.getContractFactory('BaluniV1PoolRegistry')
  await upgrades.prepareUpgrade('', BaluniV1PoolRegistry)
  const baluniPoolRegistry = await upgrades.upgradeProxy('', BaluniV1PoolRegistry, {
    kind: 'uups',
  })
  await baluniPoolRegistry?.waitForDeployment()
  console.log('BaluniV1PoolRegistry upgraded to:', baluniPoolRegistry.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
