import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1Pool = await ethers.getContractFactory('BaluniV1Pool')
  await upgrades.prepareUpgrade('', BaluniV1Pool)
  const baluniPool = await upgrades.upgradeProxy('', BaluniV1Pool, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: [
        '',
        '',
        [],
        [],
        '',
        2, // baluni registry
      ],
    },
  })
  await baluniPool?.waitForDeployment()
  console.log('BaluniV1Pool upgraded to:', baluniPool.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
