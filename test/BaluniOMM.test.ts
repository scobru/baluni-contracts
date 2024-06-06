/* eslint-disable prefer-const */
import { expect } from 'chai'
import { ethers, upgrades } from 'hardhat'
import { formatUnits, Signer } from 'ethers'
import {
  BaluniV1Pool,
  BaluniV1PoolPeriphery,
  MockRebalancer,
  MockToken,
  BaluniV1PoolRegistry,
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
  let poolRegistry: BaluniV1PoolRegistry
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

    console.log('Deploying BaluniV1PoolRegistry')
    const BaluniV1PoolRegistry = await ethers.getContractFactory('BaluniV1PoolRegistry')
    poolRegistry = (await upgrades.deployProxy(BaluniV1PoolRegistry, [
      await registry.getAddress(),
    ])) as unknown as BaluniV1PoolRegistry
    await poolRegistry.waitForDeployment()
    await registry.setBaluniPoolRegistry(await poolRegistry.getAddress())

    console.log('Minting Tokens')
    await usdc.mint(await owner.getAddress(), ethers.parseUnits('100000', 6))
    await usdt.mint(await owner.getAddress(), ethers.parseUnits('100000', 6))
    await wbtc.mint(await owner.getAddress(), ethers.parseUnits('100000', 8))
    await weth.mint(await owner.getAddress(), ethers.parseUnits('100000', 18))

    console.log('Creating Pool')

    console.log('Deploying BaluniV1PoolFactory')
    const BaluniV1Pool = await ethers.getContractFactory('BaluniV1Pool')
    pool = (await upgrades.deployProxy(BaluniV1Pool, [
      [await usdc.getAddress(), await usdt.getAddress(), await weth.getAddress(), await wbtc.getAddress()],
      [2500, 2500, 2500, 2500],
      50,
      await registry.getAddress(),
    ])) as unknown as BaluniV1Pool
    await pool.waitForDeployment()

    console.log(await pool.name())
    console.log(await pool.symbol())

    await poolRegistry.addPool(await pool.getAddress())
    baseAddress = await pool.baseAsset()

    console.log('Minting LP Tokens')

    await usdc.approve(pool.target, ethers.parseUnits('6000', 6))
    await usdt.approve(pool.target, ethers.parseUnits('4000', 6))
    await weth.approve(pool.target, ethers.parseUnits('4000', 18))
    await wbtc.approve(pool.target, ethers.parseUnits('4000', 8))
    await pool.approve(pool.target, ethers.parseUnits('10000', 18))

    let blockNumber = await ethers.provider.getBlockNumber()
    const block = await ethers.provider.getBlock(blockNumber)
    let deadline = block && block.timestamp ? block.timestamp + 10 : 0

    await pool
      .connect(owner)
      .deposit(
        await owner.getAddress(),
        [
          ethers.parseUnits('1000', 6),
          ethers.parseUnits('1000', 6),
          ethers.parseUnits('0.24631000000000003', 18),
          ethers.parseUnits('0.01405', 8),
        ],
        deadline
      )

    let balance = await pool.balanceOf(await owner.getAddress())
    expect(balance).to.be.gt(0)
    expect(await pool.totalSupply()).to.equal(balance)

    let lpBalance = await pool.balanceOf(await owner.getAddress())
    console.log('LP Balance: ', ethers.formatUnits(lpBalance.toString(), 18))
  })

  describe('Deployment and Initialization', function () {
    it('should deploy and initialize contracts correctly', async function () {
      expect(await registry.getWNATIVE()).to.equal(await wmatic.getAddress())
      expect(await registry.getUSDC()).to.equal(await usdc.getAddress())
      expect(await registry.get1inchSpotAgg()).to.equal(_1INCHSPOTAGG)
      expect(await registry.getTreasury()).to.equal(await owner.getAddress())
      expect(await registry.getUniswapFactory()).to.equal(uniswapFactory)
      expect(await registry.getUniswapRouter()).to.equal(uniswapRouter)
      expect(await registry.getBaluniOracle()).to.equal(await oracle.getAddress())
      expect(await registry.getBaluniSwapper()).to.equal(await swapper.getAddress())
      expect(await registry.getBaluniRebalancer()).to.equal(await rebalancer.getAddress())
      expect(await registry.getBaluniPoolPeriphery()).to.equal(await periphery.getAddress())
      expect(await registry.getBaluniPoolRegistry()).to.equal(await poolRegistry.getAddress())
      expect(await pool.baseAsset()).to.equal(await usdc.getAddress())
    })
  })

  describe('Burning LP Tokens', function () {
    it('should burn LP tokens correctly', async function () {
      console.log('Minting More LP Tokens')

      let lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance 2: ', ethers.formatUnits(lpBalance.toString(), 18))

      const totvals = await pool.totalValuation()
      const baseDecimals = await usdc.decimals()

      console.log('Total Valuation Before Swap and Rebalance:', ethers.formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC:', ethers.formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT:', ethers.formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH:', ethers.formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC:', ethers.formatUnits(totvals[1][3], baseDecimals))

      let blockNumber = await ethers.provider.getBlockNumber()
      const block = await ethers.provider.getBlock(blockNumber)
      let deadline = block && block.timestamp ? block.timestamp + 10 : 0

      console.log('Burning LP Tokens')
      lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance 3: ', ethers.formatUnits(lpBalance.toString(), 18))

      let reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      await pool.connect(owner).approve(pool.target, lpBalance)
      console.log(await pool.calculateAssetShare(lpBalance))
      console.log(lpBalance)
      console.log(await pool.totalSupply())
      await pool.connect(owner).withdraw(lpBalance, await owner.getAddress(), deadline)

      const pooFee = await registry.getBPS_FEE()
      const fee = (lpBalance * BigInt(pooFee) * 1n) / 10000n

      expect(await pool.totalSupply()).to.equal(BigInt(fee))
      console.log('LP Tokens Minted and Burned Successfully')
    })
  })

  describe('Token Swapping', function () {
    it('should swap tokens correctly', async function () {
      console.log('Swapping')
      await usdt.connect(owner).approve(await pool.getAddress(), ethers.MaxUint256)
      await usdc.connect(owner).approve(await pool.getAddress(), ethers.MaxUint256)
      await weth.connect(owner).approve(await pool.getAddress(), ethers.MaxUint256)
      await wbtc.connect(owner).approve(await pool.getAddress(), ethers.MaxUint256)

      await usdt.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)
      await usdc.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)
      await weth.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)
      await wbtc.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)

      let reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      let blockNumber = await ethers.provider.getBlockNumber()
      let deadline = (await ethers.provider.getBlock(blockNumber)).timestamp + 10

      console.log('Swap to Pool')
      await usdc.connect(owner).approve(await pool.getAddress(), ethers.parseUnits('50', 6))
      let usdtBalanceB4 = await usdt.balanceOf(await owner.getAddress())

      await pool
        .connect(owner)
        .swap(
          await usdc.getAddress(),
          await usdt.getAddress(),
          ethers.parseUnits('50', 6),
          0,
          await owner.getAddress(),
          deadline
        )

      let usdtBalance = await usdt.balanceOf(await owner.getAddress())
      console.log(usdtBalance - usdtBalanceB4)
      expect(usdtBalance - usdtBalanceB4).to.be.gt(ethers.parseUnits('47', 6))

      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves After Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      console.log('Pool Swap Completed Successfully')

      usdtBalanceB4 = await usdt.balanceOf(await owner.getAddress())

      await periphery
        .connect(owner)
        .swapTokenForToken(
          await usdc.getAddress(),
          await usdt.getAddress(),
          ethers.parseUnits('50', 6),
          0,
          await owner.getAddress(),
          await owner.getAddress(),
          deadline
        )

      usdtBalance = await usdt.balanceOf(await owner.getAddress())
      console.log(usdtBalance - usdtBalanceB4)
      expect(usdtBalance - usdtBalanceB4).to.be.gt(ethers.parseUnits('47', 6))

      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves After Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      console.log('Periphery Swap Completed Successfully')
    })
  })

  describe('Swapping and Rebalancing', function () {
    it('should swap and rebalance the pool correctly', async function () {
      let totvals = await pool.totalValuation()
      const baseDecimals = await usdc.decimals()

      console.log('Total Valuation Before Swap and Rebalance:', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC:', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT:', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH:', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC:', formatUnits(totvals[1][3], baseDecimals))

      const reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      let deviation = await pool.getDeviations()
      console.log('Deviation Before Swap:', deviation.toString())

      await usdt.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)
      await usdc.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)
      await weth.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)
      await wbtc.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)

      console.log('Performing Batch Swap 1')
      let fromTokens = [await weth.getAddress(), await wbtc.getAddress()]
      let amounts = [ethers.parseUnits('0.01', 18), ethers.parseUnits('0.005', 8)]
      let toTokens = [await usdt.getAddress(), await weth.getAddress()]
      let receivers = [await owner.getAddress(), await owner.getAddress()]

      await periphery.connect(owner).batchSwap(fromTokens, toTokens, amounts, receivers)

      totvals = await pool.totalValuation()
      console.log('Total Valuation After Batch Swap 1:', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC:', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT:', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH:', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC:', formatUnits(totvals[1][3], baseDecimals))

      console.log('Performing Batch Swap 2')
      fromTokens = [await wbtc.getAddress(), await weth.getAddress()]
      toTokens = [await weth.getAddress(), await usdc.getAddress()]
      amounts = [ethers.parseUnits('0.005', 8), ethers.parseUnits('0.025', 18)]
      receivers = [await owner.getAddress(), await owner.getAddress()]

      await periphery.connect(owner).batchSwap(fromTokens, toTokens, amounts, receivers)

      deviation = await pool.getDeviations()
      console.log('Deviation Before Rebalance:', deviation.toString())

      console.log('Performing Rebalance 1')
      await pool.rebalanceAndDeposit(await owner.getAddress())

      deviation = await pool.getDeviations()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      totvals = await pool.totalValuation()
      console.log('Total Valuation After Rebalance 1:', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC:', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT:', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH:', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC:', formatUnits(totvals[1][3], baseDecimals))

      deviation = await pool.getDeviations()
      console.log('Deviation After Batch Swap 2:', deviation.toString())

      console.log('Performing Batch Swap 3')
      fromTokens = [await usdt.getAddress(), await weth.getAddress()]
      toTokens = [await weth.getAddress(), await usdc.getAddress()]
      amounts = [ethers.parseUnits('200', 6), ethers.parseUnits('0.1', 18)]
      receivers = [await owner.getAddress(), await owner.getAddress()]

      await periphery.connect(owner).batchSwap(fromTokens, toTokens, amounts, receivers)

      deviation = await pool.getDeviations()
      console.log('Deviation After Batch Swap 3:', deviation.toString())
    })
  })

  describe('Slippage Test', function () {
    it('Swap and Increase Slippage', async function () {
      let balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      let balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())

      let reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      let deviation = await pool.getDeviations()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      let slippages = await pool.getSlippageParams()
      console.log('Slippages After Rebalance 1:', slippages.toString())

      const fromTokens = [await usdc.getAddress()]
      const amounts = [ethers.parseUnits('300', 6)]
      const toTokens = [await wbtc.getAddress()]
      const receivers = [await owner.getAddress()]

      await usdt.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)
      await usdc.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)
      await weth.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)
      await wbtc.connect(owner).approve(await periphery.getAddress(), ethers.MaxUint256)

      await periphery.connect(owner).batchSwap(fromTokens, toTokens, amounts, receivers)

      let balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      let balanceUsdc = await usdc.balanceOf(await owner.getAddress())

      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))

      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())

      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )
      deviation = await pool.getDeviations()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippageParams()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())

      let blockNumber = await ethers.provider.getBlockNumber()
      let deadline = (await ethers.provider.getBlock(blockNumber)).timestamp + 10

      await periphery
        .connect(owner)
        .swapTokenForToken(
          await wbtc.getAddress(),
          await usdc.getAddress(),
          ethers.parseUnits('0.00291707', 8),
          0,
          await owner.getAddress(),
          await owner.getAddress(),
          deadline
        )

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())
      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))

      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )
      deviation = await pool.getDeviations()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippageParams()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      blockNumber = await ethers.provider.getBlockNumber()
      deadline = (await ethers.provider.getBlock(blockNumber)).timestamp + 10

      await pool
        .connect(owner)
        .swap(
          await usdc.getAddress(),
          await wbtc.getAddress(),
          ethers.parseUnits('800', 6),
          0,
          await owner.getAddress(),
          deadline
        )

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())
      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))

      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )
      deviation = await pool.getDeviations()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippageParams()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      blockNumber = await ethers.provider.getBlockNumber()
      deadline = (await ethers.provider.getBlock(blockNumber)).timestamp + 10

      await pool
        .connect(owner)
        .swap(
          await usdc.getAddress(),
          await wbtc.getAddress(),
          ethers.parseUnits('50', 6),
          0,
          await owner.getAddress(),
          deadline
        )

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())
      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())

      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))

      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())

      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )
      deviation = await pool.getDeviations()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippageParams()
      console.log('Slippages After Rebalance 1:', slippages.toString())

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())
      blockNumber = await ethers.provider.getBlockNumber()
      deadline = (await ethers.provider.getBlock(blockNumber)).timestamp + 10

      await periphery
        .connect(owner)
        .swapTokenForToken(
          await wbtc.getAddress(),
          await usdc.getAddress(),
          ethers.parseUnits('0.00341031', 8),
          0,
          await owner.getAddress(),
          await owner.getAddress(),
          deadline
        )

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())
      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))

      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )
      deviation = await pool.getDeviations()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippageParams()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      blockNumber = await ethers.provider.getBlockNumber()
      deadline = (await ethers.provider.getBlock(blockNumber)).timestamp + 10

      await pool
        .connect(owner)
        .swap(
          await wbtc.getAddress(),
          await usdc.getAddress(),
          ethers.parseUnits('0.00341031', 8),
          0,
          await owner.getAddress(),
          deadline
        )

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())
      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))

      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )
      deviation = await pool.getDeviations()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippageParams()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      blockNumber = await ethers.provider.getBlockNumber()
      deadline = (await ethers.provider.getBlock(blockNumber)).timestamp + 10

      await periphery
        .connect(owner)
        .swapTokenForToken(
          await wbtc.getAddress(),
          await usdc.getAddress(),
          ethers.parseUnits('0.00341031', 8),
          0,
          await owner.getAddress(),
          await owner.getAddress(),
          deadline
        )

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())
      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))
      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )
      deviation = await pool.getDeviations()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippageParams()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      blockNumber = await ethers.provider.getBlockNumber()
      deadline = (await ethers.provider.getBlock(blockNumber)).timestamp + 10

      await pool
        .connect(owner)
        .swap(
          await usdc.getAddress(),
          await wbtc.getAddress(),
          ethers.parseUnits('216.879881', 6),
          0,
          await owner.getAddress(),
          deadline
        )

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())
      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))
    })
  })
})
