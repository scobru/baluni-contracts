import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1Router = await ethers.getContractFactory('BaluniV1Router')
  await upgrades.prepareUpgrade('', BaluniV1Router)
  const baluniRouter = await upgrades.upgradeProxy('', BaluniV1Router, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['', 2],
    },
  })
  await baluniRouter?.waitForDeployment()
  console.log('BaluniV1Router upgraded to:', baluniRouter.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
