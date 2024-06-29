import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'

async function main() {
  const BaluniV1Swapper = await ethers.getContractFactory('BaluniV1Swapper')
  const chainId = 137
  const proxyAddress = contracts[chainId].BaluniV1Swapper

  await upgrades.prepareUpgrade(proxyAddress, BaluniV1Swapper)
  const swapper = await upgrades.upgradeProxy(proxyAddress, BaluniV1Swapper, {
    kind: 'uups',
    // call: {
    //   fn: 'reinitialize',
    //   args: ['0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', 2],
    // },
  })
  await swapper?.waitForDeployment()
  console.log('BaluniV1Swapper upgraded to:', swapper.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
