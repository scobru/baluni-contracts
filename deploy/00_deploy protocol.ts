/* eslint-disable @typescript-eslint/no-unused-vars */
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers, upgrades } from 'hardhat'
import erc20ABI from '../abis/common/ERC20.json'

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */

/// Deploy -----------------------------------------------------------------------
const USDC = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174'
const WNATIVE = '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270'
const _1INCHSPOTAGG = '0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8' // 1inch Spot Aggregator
const uniswapRouter = '0xE592427A0AEce92De3Edee1F18E0157C05861564'
const uniswapFactory = '0x1F98431c8aD98523631AE4a59f267346ea31F984'

const USDC = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174'
const WNATIVE = '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270'
const USDT = '0xc2132d05d31c914a87c6611c10748aeb04b58e8f'
const WBTC = '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6'
const WETH = '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619'

const deployProtocol: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const BaluniV1PoolPeriphery = await ethers.getContractFactory('BaluniV1PoolPeriphery')
  const baluniV1PoolPeriphery = await upgrades.deployProxy(
    BaluniV1PoolPeriphery,
    [await instancePoolFactory.getAddress()], // PoolFactory
    {
      kind: 'uups',
    }
  )
  const instancePoolPeriphery = await baluniV1PoolPeriphery?.waitForDeployment()
  console.log('BaluniV1PoolPeriphery deployed to:', instancePoolPeriphery.target)

  console.log('Change periphery')
  instancePoolFactory.connect(signers[0])

  await instancePoolFactory.changePeriphery(instancePoolPeriphery.target)
  await new Promise((resolve) => setTimeout(resolve, 10000))

  await instancePoolFactory.createPool([USDT, USDC], [5000, 5000], 500)
  await instancePoolFactory.createPool([WBTC, USDC, WETH], [5000, 3000, 2000], 500)
  await instancePoolFactory.createPool([WETH, USDC], [8000, 2000], 500)
  await instancePoolFactory.createPool([WNATIVE, USDC], [8000, 2000], 500)

  const BaluniV1AgentFactory = await ethers.getContractFactory('BaluniV1AgentFactory')
  const agentFactory = await upgrades.deployProxy(BaluniV1AgentFactory, {
    kind: 'uups',
  })
  const instanceAgentFactory = await agentFactory?.waitForDeployment()
  console.log('BaluniV1AgentFactory deployed to:', instanceAgentFactory.target)

  const BaluniV1Router = await ethers.getContractFactory('BaluniV1Router')
  const baluniRouter = await upgrades.deployProxy(
    BaluniV1Router,
    [USDC, WNATIVE, _1INCHSPOTAGG, uniswapRouter, uniswapFactory, ethers.ZeroAddress, instancePoolPeriphery.target],
    {
      kind: 'uups',
    }
  )
  const instanceRouter = await baluniRouter?.waitForDeployment()
  console.log('BaluniV1Router deployed to:', instanceRouter.target)

  const BaluniV1Rebalancer = await ethers.getContractFactory('BaluniV1Rebalancer')
  const baluniRebalancer = await upgrades.deployProxy(
    BaluniV1Rebalancer,
    [instanceRouter.target, USDC, WNATIVE, uniswapRouter, uniswapFactory, _1INCHSPOTAGG],
    { kind: 'uups' }
  )
  const instanceRebalance = await baluniRebalancer?.waitForDeployment()
  console.log('BaluniV1Rebalance deployed to:', instanceRebalance.target)

  console.log('Change Router in Agent Factory')

  await instanceAgentFactory.changeRouter(instanceRouter.target)
  console.log('Set Agent Factory in Router')

  await instanceRouter.changeRebalancer(instanceRebalance.target)
  console.log('Set Rebalancer in Router')

  const BaluniV1PoolFactory = await ethers.getContractFactory('BaluniV1PoolFactory')
  const baluniV1PoolFactory = await upgrades.deployProxy(BaluniV1PoolFactory, [instanceRebalance.target], {
    kind: 'uups',
  })
  const instancePoolFactory = await baluniV1PoolFactory?.waitForDeployment()
  console.log('BaluniV1PoolFactory deployed to:', instancePoolFactory.target)
}

export default deployProtocol

deployProtocol.tags = ['deploy-protocol']
