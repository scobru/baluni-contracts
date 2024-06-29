import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1DCAVault = await ethers.getContractFactory('BaluniV1DCAVault')
  const baluniDCAVault = await upgrades.upgradeProxy('', BaluniV1DCAVault, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['', '', , , '', , 2],
    },
  })
  await baluniDCAVault?.waitForDeployment()
  console.log('BaluniV1DCAVault upgraded to:', baluniDCAVault.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
