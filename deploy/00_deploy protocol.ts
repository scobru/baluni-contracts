/* eslint-disable @typescript-eslint/no-unused-vars */
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers, upgrades } from 'hardhat'
import fs from 'fs'
import path from 'path'
import {
  BaluniV1IndexFund,
  BaluniV1DCAVault,
  BaluniV1YearnVault,
  BaluniV1Rebalancer,
  BaluniV1IndexRegistry,
  BaluniV1Registry,
  BaluniV1Swapper,
  BaluniV1Oracle,
  BaluniV1YearnVaultRegistry,
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
const STATICORACLE = '0xB210CE856631EeEB767eFa666EC7C1C57738d438'

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
  const { deployer } = await hre.getNamedAccounts()
  console.log('deployer', deployer)
  const chainId = Number(network.config.chainId)
  const deploymentInfo: any = {}

  // Deploy Registry
  const BaluniV1Registry = await ethers.getContractFactory('BaluniV1Registry')
  const baluniV1Registry = (await upgrades.deployProxy(BaluniV1Registry, [], {
    kind: 'uups',
  })) as unknown as BaluniV1Registry
  const registry = await baluniV1Registry?.waitForDeployment()

  console.log('BaluniV1Registry deployed to:', registry.target)
  deploymentInfo.BaluniV1Registry = registry.target

  // Configure Registry
  await registry.setWNATIVE(WNATIVE)
  await registry.setUSDC(USDC)
  await registry.set1inchSpotAgg(_1INCHSPOTAGG)
  await registry.setTreasury(TREASURY)
  await registry.setUniswapFactory(uniswapFactory)
  await registry.setUniswapRouter(uniswapRouter)
  await registry.setBaluniRegistry(await registry.getAddress())
  await registry.setStaticOracle(STATICORACLE)

  // Deploy Swapper
  const BaluniV1Swapper = await ethers.getContractFactory('BaluniV1Swapper')
  const baluniSwapper = await upgrades.deployProxy(BaluniV1Swapper, [await registry.getAddress()], {
    kind: 'uups',
  })
  const instanceSwapper = (await baluniSwapper?.waitForDeployment()) as unknown as BaluniV1Swapper

  console.log('BaluniV1Swapper deployed to:', instanceSwapper.target)
  deploymentInfo.BaluniV1Swapper = instanceSwapper.target
  await registry.setBaluniSwapper(await instanceSwapper.target)

  // Deploy Oracle
  const BaluniV1Oracle = await ethers.getContractFactory('BaluniV1Oracle')
  const baluniOracle = (await upgrades.deployProxy(BaluniV1Oracle, [await registry.getAddress()], {
    kind: 'uups',
  })) as unknown as BaluniV1Oracle
  const instanceOracle = await baluniOracle?.waitForDeployment()

  console.log('BaluniV1Oracle deployed to:', instanceOracle.target)
  deploymentInfo.BaluniV1Oracle = instanceOracle.target
  await registry.setBaluniOracle(await instanceOracle.target)

  // Deploy Rebalancer
  const BaluniV1Rebalancer = await ethers.getContractFactory('BaluniV1Rebalancer')
  const baluniRebalancer = (await upgrades.deployProxy(BaluniV1Rebalancer, [await registry.getAddress()], {
    kind: 'uups',
  })) as unknown as BaluniV1Rebalancer
  const instanceRebalance = await baluniRebalancer?.waitForDeployment()

  console.log('BaluniV1Rebalancer deployed to:', instanceRebalance.target)
  deploymentInfo.BaluniV1Rebalancer = instanceRebalance.target
  await registry.setBaluniRebalancer(await instanceRebalance.target)

  // Deploy Index Registry
  const BaluniV1IndexRegistry = await ethers.getContractFactory('BaluniV1IndexRegistry')
  const baluniV1IndexRegistry = (await upgrades.deployProxy(BaluniV1IndexRegistry, [await registry.getAddress()], {
    kind: 'uups',
  })) as unknown as BaluniV1IndexRegistry
  await baluniV1IndexRegistry?.waitForDeployment()

  console.log('BaluniV1IndexRegistry deployed to:', baluniV1IndexRegistry.target)
  deploymentInfo.BaluniV1IndexRegistry = baluniV1IndexRegistry.target

  // Deploy Index Funds
  const BaluniV1IndexFund = await ethers.getContractFactory('BaluniV1IndexFund')

  const indexFundStable = (await upgrades.deployProxy(
    BaluniV1IndexFund,
    [
      'Baluni Index: Stable',
      'BI-STBL',
      [USDC, USDC_E, USDT, DAI],
      [2500, 2500, 2500, 2500],
      await registry.getAddress(),
    ],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1IndexFund
  await indexFundStable?.waitForDeployment()

  console.log('BaluniV1IndexFund Stable deployed to:', indexFundStable.target)
  deploymentInfo.BaluniIndexStable = indexFundStable.target
  await baluniV1IndexRegistry.addIndex(indexFundStable.target)

  const indexFundBalanced = (await upgrades.deployProxy(
    BaluniV1IndexFund,
    [
      'Baluni Index: Balanced',
      'BI-BAL',
      [WBTC, WETH, WNATIVE],
      [5000, 3000, 2000],
      await registry.getAddress(),
    ],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1IndexFund
  await indexFundBalanced?.waitForDeployment()

  console.log('BaluniV1IndexFund Balanced deployed to:', indexFundBalanced.target)
  deploymentInfo.BaluniIndexBalanced = indexFundBalanced.target
  await baluniV1IndexRegistry.addIndex(indexFundBalanced.target)

  const indexFundConservative = (await upgrades.deployProxy(
    BaluniV1IndexFund,
    [
      'Baluni Index: Conservative',
      'BI-CNSV',
      [WBTC, WETH],
      [8000, 2000],
      await registry.getAddress(),
    ],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1IndexFund
  await indexFundConservative?.waitForDeployment()

  console.log('BaluniV1IndexFund Conservative deployed to:', indexFundConservative.target)
  deploymentInfo.BaluniIndexConservative = indexFundConservative.target
  await baluniV1IndexRegistry.addIndex(indexFundConservative.target)

  const indexFundModerate = (await upgrades.deployProxy(
    BaluniV1IndexFund,
    [
      'Baluni Index: Moderate',
      'BI-MOD',
      [WNATIVE, USDC],
      [6000, 4000],
      await registry.getAddress(),
    ],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1IndexFund
  await indexFundModerate?.waitForDeployment()

  console.log('BaluniV1IndexFund Moderate deployed to:', indexFundModerate.target)
  deploymentInfo.BaluniIndexModerate = indexFundModerate.target
  await baluniV1IndexRegistry.addIndex(indexFundModerate.target)

  // Deploy DCA Vault Registry
  const BaluniV1DCAVaultRegistry = await ethers.getContractFactory('BaluniV1DCAVaultRegistry')
  const baluniV1DCAVaultRegistry = (await upgrades.deployProxy(
    BaluniV1DCAVaultRegistry,
    [await registry.getAddress()],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1YearnVaultRegistry
  const instanceDCAVaultRegistry = await baluniV1DCAVaultRegistry?.waitForDeployment()

  console.log('BaluniDCAVaultRegistry deployed to:', baluniV1DCAVaultRegistry.target)
  deploymentInfo.BaluniDCAVaultRegistry = baluniV1DCAVaultRegistry.target

  // Deploy DCA Vault
  const BaluniV1DCAVault = await ethers.getContractFactory('BaluniV1DCAVault')
  const baluniDCAVault = (await upgrades.deployProxy(
    BaluniV1DCAVault,
    ['Baluni Vault: DCA USDCxWBTC', 'BV-DCA', USDC, WBTC, await registry.getAddress(), 28800],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1DCAVault
  await baluniDCAVault?.waitForDeployment()

  console.log('BaluniV1DCAVault deployed to:', baluniDCAVault.target)
  await instanceDCAVaultRegistry.addVault(baluniDCAVault.target)
  deploymentInfo.BaluniVaultDCA_USDCxWBTC = baluniDCAVault.target
  saveDeploymentInfo(chainId, deploymentInfo)

  // Deploy Yearn Vault Registry
  const BaluniV1YearnVaultRegistry = await ethers.getContractFactory('BaluniV1YearnVaultRegistry')
  const baluniV1YearnVaultRegistry = (await upgrades.deployProxy(
    BaluniV1YearnVaultRegistry,
    [await registry.getAddress()],
    {
      kind: 'uups',
    }
  )) as unknown as BaluniV1YearnVaultRegistry
  await baluniV1YearnVaultRegistry?.waitForDeployment()

  console.log('BaluniV1YearnVaultRegistry deployed to:', baluniV1YearnVaultRegistry.target)
  deploymentInfo.BaluniV1YearnVaultRegistry = baluniV1YearnVaultRegistry.target

  // Deploy Yearn Vault
  const BaluniV1YearnVault = await ethers.getContractFactory('BaluniV1YearnVault')
  const baluniV1YearnVault = await upgrades.deployProxy(
    BaluniV1YearnVault,
    [
      'Baluni Vault: Yearn USDCxWBTC',
      'BV-YRN',
      USDC,
      '0x34b9421Fe3d52191B64bC32ec1aB764dcBcDbF5e', // yearn vault
      WBTC,
      await registry.getAddress(),
    ],
    {
      kind: 'uups',
    }
  )
  await baluniV1YearnVault?.waitForDeployment()

  console.log('BaluniV1YearnVault deployed to:', baluniV1YearnVault.target)
  deploymentInfo.BaluniVaultYearn_USDCxWBTC = baluniV1YearnVault.target
  saveDeploymentInfo(chainId, deploymentInfo)
  await baluniV1YearnVaultRegistry.addVault(baluniV1YearnVault.target)
}

export default deployProtocol

deployProtocol.tags = ['deploy-protocol']
