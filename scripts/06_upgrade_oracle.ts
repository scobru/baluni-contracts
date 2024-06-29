import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1Oracle = await ethers.getContractFactory('BaluniV1Oracle')
  await upgrades.prepareUpgrade('', BaluniV1Oracle)
  const baluniOracle = await upgrades.upgradeProxy('', BaluniV1Oracle, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['', 2],
    },
  })
  await baluniOracle?.waitForDeployment()
  console.log('BaluniV1Oracle upgraded to:', baluniOracle.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
