import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1PoolPeriphery = await ethers.getContractFactory('BaluniV1PoolPeriphery')
  await upgrades.prepareUpgrade('', BaluniV1PoolPeriphery)
  const baluniPeriphery = await upgrades.upgradeProxy('', BaluniV1PoolPeriphery, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['', 2],
    },
  })
  const instancePeriphery = await baluniPeriphery?.waitForDeployment()
  console.log('BaluniV1Periphery upgraded to:', instancePeriphery.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
