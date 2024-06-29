import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'

async function main() {
  const BaluniV1DCAVault = await ethers.getContractFactory('BaluniV1DCAVault')
  const chainId = 137
  const proxyAddress = contracts[chainId].BaluniVaultDCA_USDCxWBTC

  const baluniDCAVault = await upgrades.upgradeProxy(proxyAddress, BaluniV1DCAVault, {
    kind: 'uups',
    /* call: {
      fn: 'reinitialize',
      args: ['', '', , , '', , 2],
    }, */
  })
  await baluniDCAVault?.waitForDeployment()
  console.log('BaluniV1DCAVault upgraded to:', baluniDCAVault.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
