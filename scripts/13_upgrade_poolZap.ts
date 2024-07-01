import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'
import { BaluniV1PoolZap } from '../typechain-types/contracts/managers/BaluniV1PoolZap.sol/BaluniV1PoolZap'

async function main() {
  const chainId = 137
  const proxyAddress = contracts[chainId].BaluniV1PoolZap
  // const registryAddress = contracts[chainId].BaluniV1Registry
  const BaluniV1PoolZap = await ethers.getContractFactory('BaluniV1PoolZap')
  await upgrades.prepareUpgrade(proxyAddress, BaluniV1PoolZap)
  const baluniPoolZap = (await upgrades.upgradeProxy(proxyAddress, BaluniV1PoolZap, {
    kind: 'uups',
  })) as unknown as BaluniV1PoolZap
  await baluniPoolZap?.waitForDeployment()
  console.log('BaluniV1PoolZap upgraded to:', baluniPoolZap.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
