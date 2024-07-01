/* eslint-disable @typescript-eslint/no-unused-vars */
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers, upgrades } from 'hardhat'
import contracts from '../deployments/deployedContracts.json'

import { BaluniV1PoolZap } from '../typechain-types'

const deployPoolZap: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { network } = hre
  const { deployer } = await hre.getNamedAccounts()
  console.log('deployer', deployer)

  const chainId = 137
  const registry = contracts[chainId].BaluniV1Registry
  const BaluniPoolZap = await ethers.getContractFactory('BaluniV1PoolZap')
  const baluniPoolZap = (await upgrades.deployProxy(BaluniPoolZap, [registry], {
    kind: 'uups',
  })) as unknown as BaluniV1PoolZap
  await baluniPoolZap?.waitForDeployment()

  console.log('BaluniV1PoolZap deployed to:', baluniPoolZap.target)
}
export default deployPoolZap

deployPoolZap.tags = ['deploy-poolzap']
