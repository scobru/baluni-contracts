import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1Rebalancer = await ethers.getContractFactory('BaluniV1Rebalancer')
  await upgrades.prepareUpgrade('', BaluniV1Rebalancer)
  const rebalancer = await upgrades.upgradeProxy('', BaluniV1Rebalancer, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['', 2],
    },
  })
  const instanceRebalancer = await rebalancer?.waitForDeployment()
  console.log('BaluniV1Rebalancer upgraded to:', instanceRebalancer.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
