/* eslint-disable @typescript-eslint/no-unused-vars */
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers, upgrades } from 'hardhat'
import erc20ABI from '../abis/common/ERC20.json'
import {
  BaluniV1Pool,
  BaluniV1PoolPeriphery,
  BaluniV1Rebalancer,
  BaluniV1PoolRegistry,
  BaluniV1Registry,
  BaluniV1Swapper,
  BaluniV1Oracle,
  BaluniV1AgentFactory,
  BaluniV1Router,
} from '../typechain-types'
/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */

/// Deploy -----------------------------------------------------------------------
const WNATIVE = '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270'
const _1INCHSPOTAGG = '0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8' // 1inch Spot Aggregator
const uniswapRouter = '0xE592427A0AEce92De3Edee1F18E0157C05861564'
const uniswapFactory = '0x1F98431c8aD98523631AE4a59f267346ea31F984'
const USDT = '0xc2132d05d31c914a87c6611c10748aeb04b58e8f'
const WBTC = '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6'
const WETH = '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619'
const DAI = '0x8f3cf7ad23cd3cadbd9735aff958023239c6a063'
const USDC = '0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359'
const USDC_E = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174'

const TREASURY = '0x0C01CDE1cCAcD1e47740F3728872Aeb7C69703C2'

const deployProtocol: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const BaluniV1Registry = await ethers.getContractFactory('BaluniV1Registry')
  const baluniV1Registry = await upgrades.deployProxy(BaluniV1Registry, [], { kind: 'uups' })
  const registry = await baluniV1Registry?.waitForDeployment()
  console.log('BaluniV1Registry deployed to:', registry.target)

  // set constnt
  await registry.setWNATIVE(WNATIVE)
  await registry.setUSDC(USDC)
  await registry.set1inchSpotAgg(_1INCHSPOTAGG)
  await registry.setTreasury(TREASURY)
  await registry.setUniswapFactory(uniswapFactory)
  await registry.setUniswapRouter(uniswapRouter)
  await registry.setBaluniRegistry(await registry.getAddress())

  const BaluniV1Swapper = await ethers.getContractFactory('BaluniV1Swapper')
  const baluniSwapper = await upgrades.deployProxy(BaluniV1Swapper, [await registry.getAddress()], {
    kind: 'uups',
  })
  const instanceSwapper = (await baluniSwapper?.waitForDeployment()) as unknown as BaluniV1Swapper
  console.log('BaluniV1Swapper deployed to:', instanceSwapper.target)

  await registry.setBaluniSwapper(await instanceSwapper.target)

  const BaluniV1Oracle = await ethers.getContractFactory('BaluniV1Oracle')
  const baluniOracle = (await upgrades.deployProxy(BaluniV1Oracle, [await registry.getAddress()], {
    kind: 'uups',
  })) as unknown as BaluniV1Oracle
  const instanceOracle = await baluniOracle?.waitForDeployment()
  console.log('BaluniV1Oracle deployed to:', instanceOracle.target)

  await registry.setBaluniOracle(await instanceOracle.target)

  const BaluniV1Rebalancer = await ethers.getContractFactory('BaluniV1Rebalancer')
  const baluniRebalancer = (await upgrades.deployProxy(BaluniV1Rebalancer, [await registry.getAddress()], {
    kind: 'uups',
  })) as unknown as BaluniV1Rebalancer
  const instanceRebalance = await baluniRebalancer?.waitForDeployment()
  console.log('BaluniV1Rebalance deployed to:', instanceRebalance.target)

  await registry.setBaluniRebalancer(await instanceRebalance.target)

  const BaluniV1AgentFactory = await ethers.getContractFactory('BaluniV1AgentFactory')
  const agentFactory = (await upgrades.deployProxy(
    BaluniV1AgentFactory,
    ['0xCF4d4CCfE28Ef12d4aCEf2c9F5ebE6BE72Abe182'],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1AgentFactory
  const instanceAgentFactory = await agentFactory?.waitForDeployment()
  console.log('BaluniV1AgentFactory deployed to:', instanceAgentFactory.target)

  await registry.setBaluniAgentFactory(await instanceAgentFactory.target)

  const BaluniV1Router = await ethers.getContractFactory('BaluniV1Router')
  const baluniRouter = (await upgrades.deployProxy(BaluniV1Router, [await registry.getAddress()], {
    kind: 'uups',
  })) as unknown as BaluniV1Router
  const instanceRouter = await baluniRouter?.waitForDeployment()
  console.log('BaluniV1Router deployed to:', instanceRouter.target)

  await registry.setBaluniRouter(await instanceRouter.target)

  const BaluniV1PoolPeriphery = await ethers.getContractFactory('BaluniV1PoolPeriphery')
  const baluniV1PoolPeriphery = (await upgrades.deployProxy(
    BaluniV1PoolPeriphery,
    [await registry.getAddress()], // PoolFactory
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1PoolPeriphery
  const instancePoolPeriphery = await baluniV1PoolPeriphery?.waitForDeployment()
  console.log('BaluniV1PoolPeriphery deployed to:', instancePoolPeriphery.target)

  await registry.setBaluniPoolPeriphery(await instancePoolPeriphery.target)

  const BaluniV1PoolRegistry = await ethers.getContractFactory('BaluniV1PoolRegistry')
  const baluniV1PoolRegistry = (await upgrades.deployProxy(BaluniV1PoolRegistry, [await registry.getAddress()], {
    kind: 'uups',
  })) as unknown as BaluniV1PoolRegistry
  await baluniV1PoolRegistry?.waitForDeployment()
  console.log('BaluniV1PoolRegistry deployed to:', baluniV1PoolRegistry.target)

  await registry.setBaluniPoolRegistry(await baluniV1PoolRegistry.target)
  const BaluniV1Pool = await ethers.getContractFactory('BaluniV1Pool')
  const baluniV1Pool = (await upgrades.deployProxy(
    BaluniV1Pool,
    [
      [USDC, USDC_E, USDT, DAI],
      [2500, 2500, 2500, 2500],
      500,
      await registry.getAddress(), // PoolFactory
    ],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1Pool
  await baluniV1Pool?.waitForDeployment()
  console.log('BaluniV1PoolPeriphery deployed to:', baluniV1Pool.target)
  await baluniV1PoolRegistry.addPool(baluniV1Pool.target)

  const baluniV1Pool2 = (await upgrades.deployProxy(
    BaluniV1Pool,
    [
      [WBTC, WETH, USDC_E],
      [5000, 3000, 2000],
      500,
      await registry.getAddress(), // PoolFactory
    ],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1Pool
  await baluniV1Pool2?.waitForDeployment()
  console.log('BaluniV1PoolPeriphery deployed to:', baluniV1Pool2.target)
  await baluniV1PoolRegistry.addPool(baluniV1Pool2.target)
}

export default deployProtocol

deployProtocol.tags = ['deploy-protocol']
