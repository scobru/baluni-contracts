/* eslint-disable @typescript-eslint/no-unused-vars */
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers, upgrades } from 'hardhat'
import fs from 'fs'
import path from 'path'
import {
  BaluniV1Pool,
  BaluniV1yVaultType1,
  BaluniV1PoolPeriphery,
  BaluniV1Rebalancer,
  BaluniV1PoolRegistry,
  BaluniV1Registry,
  BaluniV1Swapper,
  BaluniV1Oracle,
  BaluniV1AgentFactory,
  BaluniV1Router,
  BaluniV1VaultRegistry,
} from '../typechain-types'

const WNATIVE = '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270'
const _1INCHSPOTAGG = '0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8' // 1inch Spot Aggregator
const uniswapRouter = '0xE592427A0AEce92De3Edee1F18E0157C05861564'
const uniswapFactory = '0x1F98431c8aD98523631AE4a59f267346ea31F984'
const USDT = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F'
const WBTC = '0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6'
const WETH = '0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619'
const DAI = '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063'
const USDC = '0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359'
const USDC_E = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174'

const TREASURY = '0x0C01CDE1cCAcD1e47740F3728872Aeb7C69703C2'

const saveDeploymentInfo = (chainId: number, deploymentInfo: any) => {
  const dir = path.resolve(__dirname, '../deployments')
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir)
  }

  const filePath = path.join(dir, 'deployedContracts.json')
  let data: { [key: string]: any } = {}

  if (fs.existsSync(filePath)) {
    data = JSON.parse(fs.readFileSync(filePath, 'utf8'))
  }

  data[String(chainId)] = deploymentInfo

  fs.writeFileSync(filePath, JSON.stringify(data, null, 2))
}

const deployProtocol: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { network } = hre
  const chainId = Number(network.config.chainId)
  const deploymentInfo: any = {}

  // const BaluniV1Registry = await ethers.getContractFactory('BaluniV1Registry')
  // const baluniV1Registry = await upgrades.deployProxy(BaluniV1Registry, [], { kind: 'uups' })
  // const registry = await baluniV1Registry?.waitForDeployment()
  // console.log('BaluniV1Registry deployed to:', registry.target)
  // deploymentInfo.BaluniV1Registry = registry.target

  // await registry.setWNATIVE(WNATIVE)
  // await registry.setUSDC(USDC)
  // await registry.set1inchSpotAgg(_1INCHSPOTAGG)
  // await registry.setTreasury(TREASURY)
  // await registry.setUniswapFactory(uniswapFactory)
  // await registry.setUniswapRouter(uniswapRouter)
  // await registry.setBaluniRegistry(await registry.getAddress())

  // const BaluniV1Swapper = await ethers.getContractFactory('BaluniV1Swapper')
  // const baluniSwapper = await upgrades.deployProxy(BaluniV1Swapper, [await registry.getAddress()], {
  //   kind: 'uups',
  // })
  // const instanceSwapper = (await baluniSwapper?.waitForDeployment()) as unknown as BaluniV1Swapper
  // console.log('BaluniV1Swapper deployed to:', instanceSwapper.target)
  // deploymentInfo.BaluniV1Swapper = instanceSwapper.target

  // await registry.setBaluniSwapper(await instanceSwapper.target)

  // const BaluniV1Oracle = await ethers.getContractFactory('BaluniV1Oracle')
  // const baluniOracle = (await upgrades.deployProxy(BaluniV1Oracle, [await registry.getAddress()], {
  //   kind: 'uups',
  // })) as unknown as BaluniV1Oracle
  // const instanceOracle = await baluniOracle?.waitForDeployment()
  // console.log('BaluniV1Oracle deployed to:', instanceOracle.target)
  // deploymentInfo.BaluniV1Oracle = instanceOracle.target

  // await registry.setBaluniOracle(await instanceOracle.target)

  // const BaluniV1Rebalancer = await ethers.getContractFactory('BaluniV1Rebalancer')
  // const baluniRebalancer = (await upgrades.deployProxy(BaluniV1Rebalancer, [await registry.getAddress()], {
  //   kind: 'uups',
  // })) as unknown as BaluniV1Rebalancer
  // const instanceRebalance = await baluniRebalancer?.waitForDeployment()
  // console.log('BaluniV1Rebalance deployed to:', instanceRebalance.target)
  // deploymentInfo.BaluniV1Rebalance = instanceRebalance.target

  // await registry.setBaluniRebalancer(await instanceRebalance.target)

  // const BaluniV1AgentFactory = await ethers.getContractFactory('BaluniV1AgentFactory')
  // const agentFactory = (await upgrades.deployProxy(BaluniV1AgentFactory, [registry.target], {
  //   kind: 'uups',
  // })) as unknown as BaluniV1AgentFactory
  // const instanceAgentFactory = await agentFactory?.waitForDeployment()
  // console.log('BaluniV1AgentFactory deployed to:', instanceAgentFactory.target)
  // deploymentInfo.BaluniV1AgentFactory = instanceAgentFactory.target

  // await registry.setBaluniAgentFactory(await instanceAgentFactory.target)

  // const BaluniV1Router = await ethers.getContractFactory('BaluniV1Router')
  // const baluniRouter = (await upgrades.deployProxy(BaluniV1Router, [await registry.getAddress()], {
  //   kind: 'uups',
  // })) as unknown as BaluniV1Router
  // const instanceRouter = await baluniRouter?.waitForDeployment()
  // console.log('BaluniV1Router deployed to:', instanceRouter.target)
  // deploymentInfo.BaluniV1Router = instanceRouter.target

  // await registry.setBaluniRouter(await instanceRouter.target)

  // const BaluniV1PoolPeriphery = await ethers.getContractFactory('BaluniV1PoolPeriphery')
  // const baluniV1PoolPeriphery = (await upgrades.deployProxy(
  //   BaluniV1PoolPeriphery,
  //   [await registry.getAddress()], // PoolFactory
  //   {
  //     kind: 'uups',
  //   }
  // )) as unknown as BaluniV1PoolPeriphery
  // const instancePoolPeriphery = await baluniV1PoolPeriphery?.waitForDeployment()
  // console.log('BaluniV1PoolPeriphery deployed to:', instancePoolPeriphery.target)
  // deploymentInfo.BaluniV1PoolPeriphery = instancePoolPeriphery.target

  // await registry.setBaluniPoolPeriphery(await instancePoolPeriphery.target)

  // const BaluniV1PoolRegistry = await ethers.getContractFactory('BaluniV1PoolRegistry')
  // const baluniV1PoolRegistry = (await upgrades.deployProxy(BaluniV1PoolRegistry, [await registry.getAddress()], {
  //   kind: 'uups',
  // })) as unknown as BaluniV1PoolRegistry
  // await baluniV1PoolRegistry?.waitForDeployment()
  // console.log('BaluniV1PoolRegistry deployed to:', baluniV1PoolRegistry.target)
  // deploymentInfo.BaluniV1PoolRegistry = baluniV1PoolRegistry.target

  // await registry.setBaluniPoolRegistry(await baluniV1PoolRegistry.target)

  // const BaluniV1Pool = await ethers.getContractFactory('BaluniV1Pool')
  // const baluniV1Pool = (await upgrades.deployProxy(
  //   BaluniV1Pool,
  //   [
  //     [USDC, USDC_E, USDT, DAI],
  //     [2500, 2500, 2500, 2500],
  //     500,
  //     await registry.getAddress(), // PoolFactory
  //   ],
  //   {
  //     kind: 'uups',
  //   }
  // )) as unknown as BaluniV1Pool
  // await baluniV1Pool?.waitForDeployment()
  // console.log('BaluniV1Pool deployed to:', baluniV1Pool.target)
  // deploymentInfo.BaluniV1Pool = baluniV1Pool.target

  // await baluniV1PoolRegistry.addPool(baluniV1Pool.target)

  // const baluniV1Pool2 = (await upgrades.deployProxy(
  //   BaluniV1Pool,
  //   [
  //     [WBTC, WETH, USDC_E],
  //     [5000, 3000, 2000],
  //     500,
  //     await registry.getAddress(), // PoolFactory
  //   ],
  //   {
  //     kind: 'uups',
  //   }
  // )) as unknown as BaluniV1Pool
  // await baluniV1Pool2?.waitForDeployment()
  // console.log('BaluniV1Pool2 deployed to:', baluniV1Pool2.target)
  // deploymentInfo.BaluniV1Pool2 = baluniV1Pool2.target

  // await baluniV1PoolRegistry.addPool(baluniV1Pool2.target)

  // // Save the deployment information to the deployment folder
  // saveDeploymentInfo(chainId, deploymentInfo)

  const BaluniV1VaultRegistry = await ethers.getContractFactory('BaluniV1VaultRegistry')
  const baluniV1VaultRegistry = (await upgrades.deployProxy(
    BaluniV1VaultRegistry,
    ['0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655' /* await registry.getAddress() */],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1VaultRegistry
  await baluniV1VaultRegistry?.waitForDeployment()
  console.log('BaluniV1VaultRegistry deployed to:', baluniV1VaultRegistry.target)
  deploymentInfo.BaluniV1VaultRegistry = baluniV1VaultRegistry.target
  //await registry.setBaluniPoolRegistry(await baluniV1PoolRegistry.target)

  //saveDeploymentInfo(chainId, deploymentInfo)

  const BaluniV1yVault = await ethers.getContractFactory('BaluniV1yVault')
  const baluniV1yVault = await upgrades.deployProxy(
    BaluniV1yVault,
    [
      'BALUNI Yearn Vault USDC Accumulator WBTC',
      'byUSDCx',
      USDC,
      '0x34b9421Fe3d52191B64bC32ec1aB764dcBcDbF5e', // yearn vault
      WBTC,
      '0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', // await registry.getAddress(),
    ],
    {
      kind: 'uups',
    }
  )

  await baluniV1yVault?.waitForDeployment()
  console.log('BaluniV1yPoolAcc deployed to:', baluniV1yVault.target)
  deploymentInfo.BaluniV1yVault = baluniV1yVault.target

  //saveDeploymentInfo(chainId, deploymentInfo)

  await baluniV1VaultRegistry.addVault(baluniV1yVault.target)
}
export default deployProtocol

deployProtocol.tags = ['deploy-protocol']
