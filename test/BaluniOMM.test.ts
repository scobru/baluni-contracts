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
      expect(await registry.getBaluniPoolFactory()).to.equal(await factory.getAddress())
      expect(await pool.baseAsset()).to.equal(await usdc.getAddress())
    })
  })

  describe('Minting and Burning LP Tokens', function () {
    beforeEach(async function () {
      // Approve tokens for periphery
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits('6000', 6))
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits('4000', 6))
      await weth.approve(await periphery.getAddress(), ethers.parseUnits('4000', 18))
      await wbtc.approve(await periphery.getAddress(), ethers.parseUnits('4000', 8))
    })

    it('should mint LP tokens correctly', async function () {
      console.log('Minting LP Tokens')

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

      let balance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Token Balance:', Number(balance))
      expect(balance).to.be.gt(0)
      expect(await pool.totalSupply()).to.equal(balance)

      let lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance: ', ethers.formatUnits(lpBalance.toString(), 18))

      console.log('Minting More LP Tokens')

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

      lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance 2: ', ethers.formatUnits(lpBalance.toString(), 18))

      const totvals = await pool.computeTotalValuation()
      const baseDecimals = await usdc.decimals()

      console.log('Total Valuation Before Swap and Rebalance:', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC:', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT:', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH:', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC:', formatUnits(totvals[1][3], baseDecimals))

      console.log('Burning LP Tokens')

      await pool.approve(await periphery.getAddress(), lpBalance)
      await periphery.connect(owner).removeLiquidity(lpBalance, await pool.getAddress(), await owner.getAddress())

      const pooFee = await registry.getBPS_FEE()
      const fee = (lpBalance * BigInt(pooFee) * 1n) / 10000n

      expect(await pool.totalSupply()).to.equal(BigInt(fee))

      console.log('LP Tokens Minted and Burned Successfully')
    })
  })

  describe('Token Swapping', function () {
    beforeEach(async function () {
      // Approve tokens for periphery
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits('6000', 6))
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits('4000', 6))
      await wbtc.approve(await periphery.getAddress(), ethers.parseUnits('4000', 8))
      await weth.approve(await periphery.getAddress(), ethers.parseUnits('4000', 18))

      // Add initial liquidity
      console.log('Adding Initial Liquidity')
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

      let lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance : ', ethers.formatUnits(lpBalance.toString(), 18))

      // Add initial liquidity
      console.log('Adding Initial Liquidity')
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

      lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance 3: ', ethers.formatUnits(lpBalance.toString(), 18))

      // Transfer tokens to addr1 and approve periphery to spend them
      await usdt.transfer(await addr1.getAddress(), ethers.parseUnits('10000', 6))
      await usdc.transfer(await addr1.getAddress(), ethers.parseUnits('10000', 6))
      await weth.transfer(await addr1.getAddress(), ethers.parseUnits('10', 18))
      await wbtc.transfer(await addr1.getAddress(), ethers.parseUnits('10', 8))

      await usdt.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      await usdc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      await weth.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      await wbtc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
    })

    it('should swap tokens correctly', async function () {
      console.log('Swapping USDC to USDT')

      let reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves Before Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      await periphery
        .connect(addr1)
        .swap(await usdc.getAddress(), await usdt.getAddress(), ethers.parseUnits('50', 6), await addr1.getAddress())

      const usdtBalance = await usdt.balanceOf(await addr1.getAddress())
      expect(usdtBalance).to.be.gt(ethers.parseUnits('47', 6))

      reservesB4Swap = await pool.getReserves()
      console.log(
        'Reserves After Swap:',
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8)
      )

      console.log('Swap Completed Successfully')
    })
  })

  describe('Swapping and Rebalancing', function () {
    beforeEach(async function () {
      // Approve tokens for periphery
      await usdc.approve(await periphery.getAddress(), ethers.MaxUint256)
      await usdt.approve(await periphery.getAddress(), ethers.MaxUint256)
      await weth.approve(await periphery.getAddress(), ethers.MaxUint256)
      await wbtc.approve(await periphery.getAddress(), ethers.MaxUint256)

      // Add initial liquidity
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

      const lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance 2: ', ethers.formatUnits(lpBalance.toString(), 18))

      // Transfer tokens to addr1 and approve periphery to spend them
      await usdt.transfer(await addr1.getAddress(), ethers.parseUnits('10000', 6))
      await usdc.transfer(await addr1.getAddress(), ethers.parseUnits('10000', 6))
      await weth.transfer(await addr1.getAddress(), ethers.parseUnits('10', 18))
      await wbtc.transfer(await addr1.getAddress(), ethers.parseUnits('10', 8))

      await usdt.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      await usdc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      await weth.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
      await wbtc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256)
    })

    it('should swap and rebalance the pool correctly', async function () {
      let totvals = await pool.computeTotalValuation()
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

      let deviation = await pool.getDeviation()
      console.log('Deviation Before Swap:', deviation.toString())

      console.log('Performing Batch Swap 1')
      let fromTokens = [await weth.getAddress(), await wbtc.getAddress()]
      let amounts = [ethers.parseUnits('0.01', 18), ethers.parseUnits('0.005', 8)]
      let toTokens = [await usdt.getAddress(), await weth.getAddress()]
      let receivers = [await addr1.getAddress(), await addr1.getAddress()]

      await periphery.connect(addr1).batchSwap(fromTokens, toTokens, amounts, receivers)

      // Verifiche per Batch Swap 1
      let reservesAfter = await pool.getReserves()

      const addr1USDTBalance = await usdt.balanceOf(await addr1.getAddress())
      const addr1USDCBalance = await usdc.balanceOf(await addr1.getAddress())

      totvals = await pool.computeTotalValuation()
      console.log('Total Valuation After Batch Swap 1:', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC:', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT:', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH:', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC:', formatUnits(totvals[1][3], baseDecimals))

      deviation = await pool.getDeviation()
      console.log('Deviation Before Rebalance:', deviation.toString())

      console.log('Performing Rebalance 1')
      await periphery.rebalanceWeights(await pool.getAddress(), await owner.getAddress())

      // Verifiche per Rebalance 1
      reservesAfter = await pool.getReserves()

      totvals = await pool.computeTotalValuation()
      console.log('Total Valuation After Rebalance 1:', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC:', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT:', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH:', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC:', formatUnits(totvals[1][3], baseDecimals))

      deviation = await pool.getDeviation()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      console.log('Performing Batch Swap 2')
      fromTokens = [await wbtc.getAddress(), await weth.getAddress()]
      toTokens = [await weth.getAddress(), await usdc.getAddress()]
      amounts = [ethers.parseUnits('0.005', 8), ethers.parseUnits('0.025', 18)]
      receivers = [await addr1.getAddress(), await addr1.getAddress()]

      await periphery.connect(addr1).batchSwap(fromTokens, toTokens, amounts, receivers)

      totvals = await pool.computeTotalValuation()
      console.log('Total Valuation After Batch Swap 2:', formatUnits(totvals[0], baseDecimals))
      console.log('Valuation USDC:', formatUnits(totvals[1][0], baseDecimals))
      console.log('Valuation USDT:', formatUnits(totvals[1][1], baseDecimals))
      console.log('Valuation WETH:', formatUnits(totvals[1][2], baseDecimals))
      console.log('Valuation WBTC:', formatUnits(totvals[1][3], baseDecimals))

      deviation = await pool.getDeviation()
      console.log('Deviation After Batch Swap 2:', deviation.toString())

      console.log('Performing Batch Swap 3')
      fromTokens = [await usdt.getAddress(), await weth.getAddress()]
      toTokens = [await weth.getAddress(), await usdc.getAddress()]
      amounts = [ethers.parseUnits('200', 6), ethers.parseUnits('0.1', 18)]
      receivers = [await addr1.getAddress(), await addr1.getAddress()]

      await periphery.connect(addr1).batchSwap(fromTokens, toTokens, amounts, receivers)

      deviation = await pool.getDeviation()
      console.log('Deviation After Batch Swap 3:', deviation.toString())
    })
  })

  describe('Slippage Test', function () {
    it('Swap and Increase Slippage', async function () {
      // Approve tokens for periphery
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits('6000', 6))
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits('4000', 6))
      await wbtc.approve(await periphery.getAddress(), ethers.parseUnits('4000', 8))
      await weth.approve(await periphery.getAddress(), ethers.parseUnits('4000', 18))

      // Add initial liquidity
      console.log('Adding Initial Liquidity')
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

      const lpBalance = await pool.balanceOf(await owner.getAddress())
      console.log('LP Balance : ', ethers.formatUnits(lpBalance.toString(), 18))
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

      let deviation = await pool.getDeviation()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      let slippages = await pool.getSlippages()
      console.log('Slippages After Rebalance 1:', slippages.toString())

      const fromTokens = [await usdc.getAddress()]
      const amounts = [ethers.parseUnits('300', 6)]
      const toTokens = [await wbtc.getAddress()]
      const receivers = [await addr1.getAddress()]

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
      deviation = await pool.getDeviation()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippages()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())

      await periphery
        .connect(owner)
        .swap(
          await wbtc.getAddress(),
          await usdc.getAddress(),
          ethers.parseUnits('0.00291707', 8),
          await owner.getAddress()
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
      deviation = await pool.getDeviation()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippages()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      await periphery
        .connect(owner)
        .swap(await usdc.getAddress(), await wbtc.getAddress(), ethers.parseUnits('300', 6), await owner.getAddress())

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
      deviation = await pool.getDeviation()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippages()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      await periphery
        .connect(owner)
        .swap(await usdc.getAddress(), await wbtc.getAddress(), ethers.parseUnits('300', 6), await owner.getAddress())

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
      deviation = await pool.getDeviation()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippages()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())

      await periphery
        .connect(owner)
        .swap(
          await wbtc.getAddress(),
          await usdc.getAddress(),
          ethers.parseUnits('0.00341031', 8),
          await owner.getAddress()
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
      deviation = await pool.getDeviation()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippages()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      await periphery
        .connect(owner)
        .swap(
          await wbtc.getAddress(),
          await usdc.getAddress(),
          ethers.parseUnits('0.00341031', 8),
          await owner.getAddress()
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
      deviation = await pool.getDeviation()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippages()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      await periphery
        .connect(owner)
        .swap(
          await wbtc.getAddress(),
          await usdc.getAddress(),
          ethers.parseUnits('0.00341031', 8),
          await owner.getAddress()
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
      deviation = await pool.getDeviation()
      console.log('Deviation After Rebalance 1:', deviation.toString())

      slippages = await pool.getSlippages()
      console.log('Slippages After Rebalance 1:', slippages.toString())
      balanceWbtcB4 = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdcB4 = await usdc.balanceOf(await owner.getAddress())
      await periphery
        .connect(owner)
        .swap(
          await usdc.getAddress(),
          await wbtc.getAddress(),
          ethers.parseUnits('216.879881', 6),
          await owner.getAddress()
        )

      balanceWbtc = await wbtc.balanceOf(await owner.getAddress())
      balanceUsdc = await usdc.balanceOf(await owner.getAddress())
      console.log('BTC Balance : ', ethers.formatUnits(balanceWbtc - balanceWbtcB4, 8))
      console.log('USD Balance : ', ethers.formatUnits(balanceUsdc - balanceUsdcB4, 6))
    })
  })
})
