/* eslint-disable @typescript-eslint/no-unused-vars */
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'

import { BaluniV1HyperPoolZap } from '../typechain-types'

const deployHyperPoolZap: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts()
  console.log('deployer', deployer)

  const hyperUniProxy = '0xBc11326CED7336EaB7f6bF456f55947C352844C2'

  const chainId = 137
  const registry = contracts[chainId].BaluniV1Registry
  const BaluniHyperPoolZap = await ethers.getContractFactory('BaluniV1HyperPoolZap')
  const baluniHyperPoolZap = (await upgrades.deployProxy(BaluniHyperPoolZap, [registry, hyperUniProxy], {
    kind: 'uups',
  })) as unknown as BaluniV1HyperPoolZap
  await baluniHyperPoolZap?.waitForDeployment()

  console.log('BaluniV1HyperPoolZap deployed to:', baluniHyperPoolZap.target)
}
export default deployHyperPoolZap

deployHyperPoolZap.tags = ['deploy-hyperpoolzap']
