import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'
import { BaluniV1PoolZap } from '../typechain-types/contracts/managers/BaluniV1PoolZap.sol/BaluniV1PoolZap'

async function main() {
  const chainId = 137
  const proxyAddress = contracts[chainId].BaluniV1HyperPoolZap
  // const registryAddress = contracts[chainId].BaluniV1Registry
  const BaluniV1HyperPoolZap = await ethers.getContractFactory('BaluniV1HyperPoolZap')
  await upgrades.prepareUpgrade(proxyAddress, BaluniV1HyperPoolZap)
  const baluniHyperPoolZap = (await upgrades.upgradeProxy(proxyAddress, BaluniV1HyperPoolZap, {
    kind: 'uups',
  })) as unknown as BaluniV1PoolZap
  await baluniHyperPoolZap?.waitForDeployment()
  console.log('BaluniV1HyperPoolZap upgraded to:', baluniHyperPoolZap.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
