import { expect } from 'chai'
import { ethers, upgrades } from 'hardhat'
import { formatUnits, Signer } from 'ethers'
import {
  BaluniV1Pool,
  BaluniV1PoolPeriphery,
  MockRebalancer,
  MockToken,
  BaluniV1PoolFactory,
  BaluniV1Registry,
  BaluniV1Swapper,
  MockOracle,
} from '../typechain-types'

const _1INCHSPOTAGG = '0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8' // 1inch Spot Aggregator
const uniswapRouter = '0xE592427A0AEce92De3Edee1F18E0157C05861564'
const uniswapFactory = '0x1F98431c8aD98523631AE4a59f267346ea31F984'

describe('BaluniV1Pool, BaluniV1PoolFactory and BaluniV1PoolPeriphery', function () {
  let pool: BaluniV1Pool
  let periphery: BaluniV1PoolPeriphery
  let factory: BaluniV1PoolFactory
  let rebalancer: MockRebalancer
  let oracle: MockOracle
  let registry: BaluniV1Registry
  let swapper: BaluniV1Swapper
  let usdc: MockToken
  let usdt: MockToken
  let wmatic: MockToken
  let weth: MockToken
  let wbtc: MockToken
  let owner: Signer
  let addr1: Signer
  let addr2: Signer
  let baseAddress: string

  beforeEach(async function () {
    ;[owner, addr1, addr2] = await ethers.getSigners()

    // Deploy Mock Tokens
    const MockToken = await ethers.getContractFactory('MockToken')
    usdc = (await MockToken.deploy('USD Coin', 'USDC', 6)) as MockToken
    await usdc.waitForDeployment()
    usdt = (await MockToken.deploy('Tether USD', 'USDT', 6)) as MockToken
    await usdt.waitForDeployment()
    wmatic = (await MockToken.deploy('WMATIC', 'WMATIC', 18)) as MockToken
    await wmatic.waitForDeployment()
    weth = (await MockToken.deploy('Wrapped Ether', 'WETH', 18)) as MockToken
    await weth.waitForDeployment()
    wbtc = (await MockToken.deploy('Wrapped Bitcoin', 'WBTC', 8)) as MockToken
    await wbtc.waitForDeployment()

    console.log('Deploying BaluniV1Registry')
    const BaluniV1Registry = await ethers.getContractFactory('BaluniV1Registry')
    registry = (await upgrades.deployProxy(BaluniV1Registry, [])) as unknown as BaluniV1Registry
    await registry.waitForDeployment()

    await registry.setWNATIVE(await wmatic.getAddress())
    await registry.setUSDC(await usdc.getAddress())
    await registry.set1inchSpotAgg(_1INCHSPOTAGG)
    await registry.setTreasury(await owner.getAddress())
    await registry.setUniswapFactory(uniswapFactory)
    await registry.setUniswapRouter(uniswapRouter)
    await registry.setBaluniRegistry(await registry.getAddress())

    console.log('Deploying BaluniOracle')
    const MockOracle = await ethers.getContractFactory('MockOracle')
    oracle = (await MockOracle.deploy(
      await usdt.getAddress(),
      await usdc.getAddress(),
      await wmatic.getAddress(),
      await weth.getAddress(),
      await wbtc.getAddress()
    )) as MockOracle
    await oracle.waitForDeployment()

    await registry.setBaluniOracle(await oracle.getAddress())

    console.log('Deploying BaluniSwapper')
    const BaluniV1Swapper = await ethers.getContractFactory('BaluniV1Swapper')
    swapper = (await upgrades.deployProxy(BaluniV1Swapper, [await registry.getAddress()])) as unknown as BaluniV1Swapper
    await swapper.waitForDeployment()

    await registry.setBaluniSwapper(await swapper.getAddress())

    console.log('Deploying MockRebalancer')
    const MockRebalancer = await ethers.getContractFactory('MockRebalancer')
    rebalancer = (await MockRebalancer.deploy(
      await usdt.getAddress(),
      await usdc.getAddress(),
      await wmatic.getAddress(),
      await weth.getAddress(),
      await wbtc.getAddress()
    )) as MockRebalancer
    await rebalancer.waitForDeployment()
    await registry.setBaluniRebalancer(await rebalancer.getAddress())

    console.log('Deploying BaluniV1PoolPeriphery')
    const BaluniV1PoolPeriphery = await ethers.getContractFactory('BaluniV1PoolPeriphery')
    periphery = (await upgrades.deployProxy(BaluniV1PoolPeriphery, [
      await registry.getAddress(),
    ])) as unknown as BaluniV1PoolPeriphery
    await periphery.waitForDeployment()
    await registry.setBaluniPoolPeriphery(await periphery.getAddress())

    console.log('Deploying BaluniV1PoolFactory')
    const BaluniV1PoolFactory = await ethers.getContractFactory('BaluniV1PoolFactory')
    factory = (await upgrades.deployProxy(BaluniV1PoolFactory, [
      await registry.getAddress(),
    ])) as unknown as BaluniV1PoolFactory
    await factory.waitForDeployment()
    await registry.setBaluniPoolFactory(await factory.getAddress())

    console.log('Minting Tokens')
    await usdc.mint(await owner.getAddress(), ethers.parseUnits('100000', 6))
    await usdt.mint(await owner.getAddress(), ethers.parseUnits('100000', 6))
    await wbtc.mint(await owner.getAddress(), ethers.parseUnits('100000', 8))
    await weth.mint(await owner.getAddress(), ethers.parseUnits('100000', 18))

    console.log('Creating Pool')
    await factory.createPool(
      [await usdc.getAddress(), await usdt.getAddress(), await weth.getAddress(), await wbtc.getAddress()],
      [2500, 2500, 2500, 2500],
      50
    )

    const poolAddress = await factory.getPoolByAssets(await usdc.getAddress(), await usdt.getAddress())
    pool = (await ethers.getContractAt('BaluniV1Pool', poolAddress)) as BaluniV1Pool

    baseAddress = await pool.baseAsset()

    console.log('Base Asset Address:', baseAddress)
    console.log('Periphery Address:', await periphery.getAddress())
  })

  describe('Minting and Burn', function () {
    it('should mint LP tokens correctly 🪙', async function () {
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits('6000', 6))
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits('4000', 6))
      await weth.approve(await periphery.getAddress(), ethers.parseUnits('4000', 18))
      await wbtc.approve(await periphery.getAddress(), ethers.parseUnits('4000', 8))

      console.log('🪙 Minting LP Tokens 🪙')

      try {
        await periphery
          .connect(owner)
          .addLiquidity(
            [
              ethers.parseUnits('1000', 6),
              ethers.parseUnits('1000', 6),
              ethers.parseUnits('0.24631000000000003', 18),
              ethers.parseUnits('0.01405', 8),
            ],
            await pool.getAddress(),
            await owner.getAddress()
          )
      } catch (error) {
        console.error('Error during addLiquidity:', error)
      }

      let balance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Token Balance:', Number(balance))
      expect(balance).to.be.gt(0)
      expect(await pool.totalSupply()).to.equal(balance)

      let baseDecimals

      if (baseAddress === (await usdc.getAddress())) {
        baseDecimals = await usdc.decimals()
      } else if (baseAddress === (await wmatic.getAddress())) {
        baseDecimals = await wmatic.decimals()
      }

      let lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance: ', ethers.formatUnits(lpBalance.toString(), 18))

      console.log('🪙 Minting LP Tokens 2 🪙')

      await periphery.addLiquidity(
        [
          ethers.parseUnits('1000', 6),
          ethers.parseUnits('1000', 6),
          ethers.parseUnits('0.24631000000000003', 18),
          ethers.parseUnits('0.01405', 8),
        ],
        await pool.getAddress(),
        await owner.getAddress()
      )

      balance = await pool.balanceOf(await owner.getAddress())
      expect(balance).to.be.gt(0)
      expect(await pool.totalSupply()).to.equal(balance)

      if (baseAddress === (await usdc.getAddress())) {
        baseDecimals = await usdc.decimals()
      } else if (baseAddress === (await wmatic.getAddress())) {
        baseDecimals = await wmatic.decimals()
      }

      lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance: ', ethers.formatUnits(lpBalance.toString(), 18))

      const totvals = await pool.computeTotalValuation()
      console.log('Total Valuation: ', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC: ', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT: ', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH: ', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC: ', formatUnits(totvals[1][3], baseDecimals))

      console.log('🪙 Burning LP Tokens 🪙')

      await pool.approve(await periphery.getAddress(), lpBalance)
      await periphery.connect(owner).removeLiquidity(lpBalance, await pool.getAddress(), await owner.getAddress())

      const pooFee = await registry.getBPS_FEE()
      const fee = (lpBalance * BigInt(pooFee) * 1n) / 10000n

      expect(await pool.totalSupply()).to.equal(BigInt(fee))

      console.log('✅ LP Tokens Minted Successfully ✅')
    })
  })

  describe('Swapping', function () {
    it('should swap USDC to USDT correctly using periphery 🔄', async function () {
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits('6000', 6))
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits('4000', 6))
      await wbtc.approve(await periphery.getAddress(), ethers.parseUnits('4000', 8))
      await weth.approve(await periphery.getAddress(), ethers.parseUnits('4000', 18))

      console.log('🔄 Swapping 🔄')

      await periphery.addLiquidity(
        [
          ethers.parseUnits('1000', 6),
          ethers.parseUnits('1000', 6),
          ethers.parseUnits('0.24631000000000003', 18),
          ethers.parseUnits('0.01405', 8),
        ],
        await pool.getAddress(),
        await owner.getAddress()
      )

      await usdt.transfer(await addr1.getAddress(), ethers.parseUnits('10000', 6))
      usdt.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      await usdc.transfer(await addr1.getAddress(), ethers.parseUnits('10000', 6))
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      await weth.transfer(await addr1.getAddress(), ethers.parseUnits('10', 18))
      weth.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      await wbtc.transfer(await addr1.getAddress(), ethers.parseUnits('10', 8))
      wbtc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      let reservesB4Swap = await pool.getReserves()
      console.log(
        '📊 Reserves Before Swap: ',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      await periphery
        .connect(addr1)
        .swap(await usdc.getAddress(), await usdt.getAddress(), ethers.parseUnits('100', 6), await addr1.getAddress())
      const usdtBalance = await usdt.balanceOf(await addr1.getAddress())

      await periphery
        .connect(addr1)
        .swap(await wbtc.getAddress(), await weth.getAddress(), ethers.parseUnits('0.01', 8), await addr1.getAddress())

      await periphery
        .connect(addr1)
        .swap(await usdc.getAddress(), await wbtc.getAddress(), ethers.parseUnits('200', 6), await addr1.getAddress())

      reservesB4Swap = await pool.getReserves()
      console.log(
        '📊 Reserves After Swap: ',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )
      expect(usdtBalance).to.be.gt(ethers.parseUnits('97', 6))
      console.log('✅ Swap Completed Successfully ✅')
    })
  })

  describe('Swapping and Rebalance', function () {
    it('should swap USDC to USDT correctly using periphery and rebalance the pool 🔄⚖️', async function () {
      await usdc.approve(await periphery.getAddress(), ethers.MaxUint256)
      await usdt.approve(await periphery.getAddress(), ethers.MaxUint256)
      await weth.approve(await periphery.getAddress(), ethers.MaxUint256)
      await wbtc.approve(await periphery.getAddress(), ethers.MaxUint256)

      await periphery.addLiquidity(
        [
          ethers.parseUnits('1000', 6),
          ethers.parseUnits('1000', 6),
          ethers.parseUnits('0.24631000000000003', 18),
          ethers.parseUnits('0.01405', 8),
        ],
        await pool.getAddress(),
        await owner.getAddress()
      )

      let totvals = await pool.computeTotalValuation()

      let baseDecimals

      if (baseAddress == (await usdc.getAddress())) {
        baseDecimals = await usdc.decimals()
      } else if (baseAddress == (await wmatic.getAddress())) {
        baseDecimals = await wmatic.decimals()
      }

      console.log('Total Valuation: ', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC: ', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT: ', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH: ', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC: ', formatUnits(totvals[1][3], baseDecimals))

      const reservesB4Swap = await pool.getReserves()

      console.log(
        '📊 Reserves Before Swap: ',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      await usdt.transfer(await addr1.getAddress(), ethers.parseUnits('10000', 6))
      usdt.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      await usdc.transfer(await addr1.getAddress(), ethers.parseUnits('10000', 6))
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      await weth.transfer(await addr1.getAddress(), ethers.parseUnits('10', 18))
      weth.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      await wbtc.transfer(await addr1.getAddress(), ethers.parseUnits('10', 8))
      wbtc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      let deviation = await pool.getDeviation()
      console.log('📉 Deviation: ', deviation.toString())

      console.log('🔄 Performing Batch Swap 1 🔄')

      let fromTokens = [await weth.getAddress(), await wbtc.getAddress()]
      let amounts = [ethers.parseUnits('0.05', 18), ethers.parseUnits('0.009', 8)]

      let toTokens = [await usdt.getAddress(), await usdc.getAddress()]
      let receivers = [await addr1.getAddress(), await addr1.getAddress()]

      usdt.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      weth.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      wbtc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      await periphery.connect(addr1).batchSwap(fromTokens, toTokens, amounts, receivers)

      let reservesAfter = await pool.getReserves()
      console.log(
        '📊 Reserves: ',
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8)
      )

      totvals = await pool.computeTotalValuation()
      console.log('Total Valuation: ', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC: ', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT: ', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH: ', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC: ', formatUnits(totvals[1][3], baseDecimals))

      await usdc.approve(await periphery.getAddress(), ethers.MaxUint256)
      await usdt.approve(await periphery.getAddress(), ethers.MaxUint256)
      await wbtc.approve(await periphery.getAddress(), ethers.MaxUint256)
      await weth.approve(await periphery.getAddress(), ethers.MaxUint256)

      console.log('⚖️ Performing Rebalance 1 ⚖️')

      deviation = await pool.getDeviation()
      console.log('📉 Deviation: ', deviation.toString())

      let poolBalances = await pool.balanceOf(await owner.getAddress())
      console.log('POOL BALANCE:', formatUnits(poolBalances, 18))

      let totalVal = await pool.computeTotalValuation()
      console.log(totalVal)

      await periphery.rebalanceWeights(await pool.getAddress(), await owner.getAddress())

      poolBalances = await pool.balanceOf(await owner.getAddress())
      console.log('POOL BALANCE:', formatUnits(poolBalances, 18))

      totalVal = await pool.computeTotalValuation()
      console.log(totalVal)

      totvals = await pool.computeTotalValuation()
      console.log('Total Valuation: ', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC: ', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT: ', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH: ', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC: ', formatUnits(totvals[1][3], baseDecimals))

      reservesAfter = await pool.getReserves()

      console.log(
        '📊 Reserves: ',
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8)
      )

      console.log('⚖️ Performing Rebalance 2 ⚖️')

      deviation = await pool.getDeviation()
      console.log('📉 Deviation: ', deviation.toString())

      await periphery.rebalanceWeights(await pool.getAddress(), await owner.getAddress())

      totvals = await pool.computeTotalValuation()
      console.log('Total Valuation: ', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC: ', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT: ', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH: ', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC: ', formatUnits(totvals[1][3], baseDecimals))

      reservesAfter = await pool.getReserves()

      console.log(
        '📊 Reserves: ',
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8)
      )

      deviation = await pool.getDeviation()
      console.log('📉 Deviation: ', deviation.toString())

      fromTokens = [await wbtc.getAddress(), await weth.getAddress()]
      toTokens = [await weth.getAddress(), await usdc.getAddress()]
      amounts = [ethers.parseUnits('0.005', 8), ethers.parseUnits('0.05', 18)]
      receivers = [await addr1.getAddress(), await addr1.getAddress()]

      usdt.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      weth.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      wbtc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      console.log('🔄 Performing Batch Swap 2 🔄')

      await periphery.connect(addr1).batchSwap(fromTokens, toTokens, amounts, receivers)

      reservesAfter = await pool.getReserves()

      totvals = await pool.computeTotalValuation()
      console.log('Total Valuation: ', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC: ', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT: ', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH: ', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC: ', formatUnits(totvals[1][3], baseDecimals))

      console.log(
        '📊 Reserves: ',
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8)
      )

      deviation = await pool.getDeviation()
      console.log('📉 Deviation: ', deviation.toString())

      fromTokens = [await usdt.getAddress(), await weth.getAddress()]
      toTokens = [await weth.getAddress(), await usdc.getAddress()]
      amounts = [ethers.parseUnits('800', 6), ethers.parseUnits('0.1', 18)]
      receivers = [await addr1.getAddress(), await addr1.getAddress()]

      usdt.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      weth.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      wbtc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)

      console.log('🔄 Performing Batch Swap  3🔄')
      await periphery.connect(addr1).batchSwap(fromTokens, toTokens, amounts, receivers)

      console.log(
        '📊 Reserves: ',
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8)
      )

      deviation = await pool.getDeviation()
      console.log('📉 Deviation: ', deviation.toString())
    })
  })
})
