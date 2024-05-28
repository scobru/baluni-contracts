/* eslint-disable prefer-const */
/* eslint-disable @typescript-eslint/no-unused-vars */

import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { formatEther, formatUnits, Signer } from "ethers";
import {
  BaluniV1Pool,
  BaluniV1PoolPeriphery,
  MockRebalancer,
  MockToken,
  BaluniV1PoolFactory,
} from "../typechain-types";

import hre from "hardhat";

describe("BaluniV1Pool, BaluniV1PoolFactory and BaluniV1PoolPeriphery", function () {
  let pool: BaluniV1Pool;
  let periphery: BaluniV1PoolPeriphery;
  let factory: BaluniV1PoolFactory;
  let rebalancer: MockRebalancer;
  let usdc: MockToken;
  let usdt: MockToken;
  let wmatic: MockToken;
  let weth: MockToken;
  let wbtc: MockToken;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy Mock Tokens
    const MockToken = await hre.ethers.getContractFactory("MockToken");
    usdc = (await MockToken.deploy("USD Coin", "USDC", 6)) as MockToken;
    await usdc.waitForDeployment();
    usdt = (await MockToken.deploy("Tether USD", "USDT", 6)) as MockToken;
    await usdt.waitForDeployment();
    wmatic = (await MockToken.deploy("WMATIC", "WMATIC", 18)) as MockToken;
    await wmatic.waitForDeployment();
    weth = (await MockToken.deploy("Wrapped Ether", "WETH", 18)) as MockToken;
    await weth.waitForDeployment();
    wbtc = (await MockToken.deploy("Wrapped Bitcoin", "WBTC", 8)) as MockToken;
    await wbtc.waitForDeployment();

    // Deploy Mock Rebalancer
    const MockRebalancer = await hre.ethers.getContractFactory("MockRebalancer");
    rebalancer = (await MockRebalancer.deploy(
      await usdt.getAddress(),
      await usdc.getAddress(),
      await wmatic.getAddress(),
      await weth.getAddress(),
      await wbtc.getAddress(),
    )) as MockRebalancer;
    await rebalancer.waitForDeployment();

    // Deploy BaluniV1PoolFactory
    const BaluniV1PoolFactory = await hre.ethers.getContractFactory("BaluniV1PoolFactory");
    factory = (await upgrades.deployProxy(BaluniV1PoolFactory, [
      await rebalancer.getAddress(),
    ])) as unknown as BaluniV1PoolFactory;
    await factory.waitForDeployment();

    // Deploy BaluniV1PoolPeriphery
    const BaluniV1PoolPeriphery = await hre.ethers.getContractFactory("BaluniV1PoolPeriphery");
    periphery = (await upgrades.deployProxy(BaluniV1PoolPeriphery, [
      await factory.getAddress(),
    ])) as unknown as BaluniV1PoolPeriphery;
    await periphery.waitForDeployment();

    await factory.changePeriphery(await periphery.getAddress());

    // Mint tokens for the owner
    await usdc.mint(await owner.getAddress(), ethers.parseUnits("100000", 6));
    await usdt.mint(await owner.getAddress(), ethers.parseUnits("100000", 6));
    await wbtc.mint(await owner.getAddress(), ethers.parseUnits("100000", 8));
    await weth.mint(await owner.getAddress(), ethers.parseUnits("100000", 18));

    // Create a new pool
    await factory.createPool(
      [await usdc.getAddress(), await usdt.getAddress(), await weth.getAddress(), await wbtc.getAddress()],
      [2500, 2500, 2500, 2500],
      500,
    );
    const poolAddress = await factory.getPoolByAssets(await usdc.getAddress(), await usdt.getAddress());
    pool = (await ethers.getContractAt("BaluniV1Pool", poolAddress)) as BaluniV1Pool;

    await rebalancer.setTreasury(await owner.getAddress());
  });

  describe("Minting and Burn", function () {
    it("should mint LP tokens correctly 🪙", async function () {
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits("6000", 6));
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits("4000", 6));
      await weth.approve(await periphery.getAddress(), ethers.parseUnits("4000", 18));
      await wbtc.approve(await periphery.getAddress(), ethers.parseUnits("4000", 8));

      console.log("🪙 Minting LP Tokens 🪙");
      console.log("USDC Balance:", formatUnits(await usdc.balanceOf(await owner.getAddress()), 6));
      console.log("USDT Balance:", formatUnits(await usdt.balanceOf(await owner.getAddress()), 6));

      await periphery.addLiquidity(
        [
          ethers.parseUnits("6000", 6),
          ethers.parseUnits("4000", 6),
          ethers.parseUnits("10", 18),
          ethers.parseUnits("10", 8),
        ],
        await pool.getAddress(),
        await owner.getAddress(),
      );
      const balance = await pool.balanceOf(await owner.getAddress());

      expect(balance).to.be.gt(0);
      expect(await pool.totalSupply()).to.equal(balance);

      const lpBalance = await pool.balanceOf(await owner.getAddress());
      console.log("LP Balance: ", ethers.formatEther(lpBalance.toString()));

      await pool.approve(await periphery.getAddress(), lpBalance);
      await periphery.connect(owner).removeLiquidity(lpBalance, await pool.getAddress(), await owner.getAddress());

      const pooFee = await pool.SWAP_FEE_BPS();
      const fee = (lpBalance * BigInt(pooFee) * 1n) / 10000n;

      expect(await pool.totalSupply()).to.equal(BigInt(fee));
      console.log("✅ LP Tokens Minted Successfully ✅");
    });
  });

  describe("Swapping", function () {
    it("should swap USDC to USDT correctly using periphery 🔄", async function () {
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits("6000", 6));
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits("4000", 6));
      await wbtc.approve(await periphery.getAddress(), ethers.parseUnits("4000", 8));
      await weth.approve(await periphery.getAddress(), ethers.parseUnits("4000", 18));

      console.log("🔄 Swapping USDC to USDT 🔄");

      await periphery.addLiquidity(
        [
          ethers.parseUnits("6000", 6),
          ethers.parseUnits("4000", 6),
          ethers.parseUnits("1", 18),
          ethers.parseUnits("1", 8),
        ],
        await pool.getAddress(),
        await owner.getAddress(),
      );

      await usdc.transfer(await addr1.getAddress(), ethers.parseUnits("100", 6));
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.parseUnits("100", 6));

      await periphery
        .connect(addr1)
        .swap(await usdc.getAddress(), await usdt.getAddress(), ethers.parseUnits("100", 6), await addr1.getAddress());
      const usdtBalance = await usdt.balanceOf(await addr1.getAddress());

      console.log("USDT Balance after swap: ", formatUnits(usdtBalance.toString(), 6));
      expect(usdtBalance).to.be.gt(ethers.parseUnits("99", 6));
      console.log("✅ Swap Completed Successfully ✅");
    });
  });

  describe("Swapping and Rebalance", function () {
    it("should swap USDC to USDT correctly using periphery and rebalance the pool 🔄⚖️", async function () {
      await usdc.approve(await periphery.getAddress(), ethers.MaxUint256);
      await usdt.approve(await periphery.getAddress(), ethers.MaxUint256);
      await weth.approve(await periphery.getAddress(), ethers.MaxUint256);
      await wbtc.approve(await periphery.getAddress(), ethers.MaxUint256);

      await periphery.addLiquidity(
        [
          ethers.parseUnits("1000", 6),
          ethers.parseUnits("1000", 6),
          ethers.parseUnits("0.24631000000000003", 18),
          ethers.parseUnits("0.01405", 8),
        ],
        await pool.getAddress(),
        await owner.getAddress(),
      );

      let totvals = await pool.computeTotalValuation();
      console.log("Total Valuation: ", formatUnits(totvals[0], 18));
      console.log("Valuation USDC: ", formatUnits(totvals[1][0], 18));
      console.log("Valuation USDT: ", formatUnits(totvals[1][1], 18));
      console.log("Valuation WETH: ", formatUnits(totvals[1][2], 18));
      console.log("Valuation WBTC: ", formatUnits(totvals[1][3], 18));

      const reservesB4Swap = await pool.getReserves();
      console.log(
        "📊 Reserves Before Swap: ",
        formatUnits(reservesB4Swap[0], 6),
        formatUnits(reservesB4Swap[1], 6),
        formatUnits(reservesB4Swap[2], 18),
        formatUnits(reservesB4Swap[3], 8),
      );

      await usdt.transfer(await addr1.getAddress(), ethers.parseUnits("10000", 6));
      usdt.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256);

      await usdc.transfer(await addr1.getAddress(), ethers.parseUnits("10000", 6));
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256);

      await weth.transfer(await addr1.getAddress(), ethers.parseUnits("10", 18));
      weth.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256);

      await wbtc.transfer(await addr1.getAddress(), ethers.parseUnits("10", 8));
      wbtc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256);

      // SWAP
      console.log("🔄 Performing Swap: USDC to WETH 🔄");
      await periphery
        .connect(addr1)
        .swap(await usdc.getAddress(), await weth.getAddress(), ethers.parseUnits("100", 6), await addr1.getAddress());

      console.log("🔄 Performing Swap: WBTC to WETH 🔄");
      await periphery
        .connect(addr1)
        .swap(
          await wbtc.getAddress(),
          await weth.getAddress(),
          ethers.parseUnits("0.005", 8),
          await addr1.getAddress(),
        );

      console.log("🔄 Performing Swap: USDC to WBTC 🔄");
      await periphery
        .connect(addr1)
        .swap(await usdt.getAddress(), await wbtc.getAddress(), ethers.parseUnits("100", 6), await addr1.getAddress());

      let deviation = await pool.getDeviation();

      console.log("📉 Deviation after swap: ", deviation.toString());

      totvals = await pool.computeTotalValuation();
      console.log("Total Valuation: ", formatUnits(totvals[0], 18));
      console.log("Valuation USDC: ", formatUnits(totvals[1][0], 18));
      console.log("Valuation USDT: ", formatUnits(totvals[1][1], 18));
      console.log("Valuation WETH: ", formatUnits(totvals[1][2], 18));
      console.log("Valuation WBTC: ", formatUnits(totvals[1][3], 18));

      const reservesBefore = await pool.getReserves();

      console.log(
        "📊 Reserves Before Rebalance: ",
        formatUnits(reservesBefore[0], 6),
        formatUnits(reservesBefore[1], 6),
        formatUnits(reservesBefore[2], 18),
        formatUnits(reservesBefore[3], 8),
      );

      await usdc.approve(await pool.getAddress(), ethers.MaxUint256);
      await usdt.approve(await pool.getAddress(), ethers.MaxUint256);
      await wbtc.approve(await pool.getAddress(), ethers.MaxUint256);
      await weth.approve(await pool.getAddress(), ethers.MaxUint256);

      console.log("⚖️ Performing Rebalance 1 ⚖️");

      await pool.rebalanceWeights(await owner.getAddress());

      totvals = await pool.computeTotalValuation();
      console.log("Total Valuation: ", formatUnits(totvals[0], 18));
      console.log("Valuation USDC: ", formatUnits(totvals[1][0], 18));
      console.log("Valuation USDT: ", formatUnits(totvals[1][1], 18));
      console.log("Valuation WETH: ", formatUnits(totvals[1][2], 18));
      console.log("Valuation WBTC: ", formatUnits(totvals[1][3], 18));

      let reservesAfter = await pool.getReserves();

      console.log(
        "📊 Reserves After Rebalance 1: ",
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8),
      );

      deviation = await pool.getDeviation();
      console.log("📉 Deviation after Rebalance 1: ", deviation.toString());

      console.log("⚖️ Performing Rebalance 2 ⚖️");

      await pool.rebalanceWeights(await owner.getAddress());

      totvals = await pool.computeTotalValuation();
      console.log("Total Valuation: ", formatUnits(totvals[0], 18));
      console.log("Valuation USDC: ", formatUnits(totvals[1][0], 18));
      console.log("Valuation USDT: ", formatUnits(totvals[1][1], 18));
      console.log("Valuation WETH: ", formatUnits(totvals[1][2], 18));
      console.log("Valuation WBTC: ", formatUnits(totvals[1][3], 18));

      reservesAfter = await pool.getReserves();

      console.log(
        "📊 Reserves After Rebalance 2: ",
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8),
      );

      deviation = await pool.getDeviation();
      console.log("📉 Deviation after Rebalance 2: ", deviation.toString());

      const toTokens = [await wbtc.getAddress(), await usdc.getAddress()];
      const fromTokens = [await weth.getAddress(), await weth.getAddress()];
      const amounts = [ethers.parseUnits("0.01", 8), ethers.parseUnits("100", 6)];
      const receivers = [await addr1.getAddress(), await addr1.getAddress()];

      usdt.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256);
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256);
      weth.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256);
      wbtc.connect(addr1).approve(await periphery.getAddress(), ethers.MaxUint256);

      // BATCH SWAP
      console.log("🔄 Performing Batch Swap 🔄");
      await periphery.connect(addr1).batchSwap(fromTokens, toTokens, amounts, receivers);

      reservesAfter = await pool.getReserves();

      totvals = await pool.computeTotalValuation();
      console.log("Total Valuation: ", formatUnits(totvals[0], 18));
      console.log("Valuation USDC: ", formatUnits(totvals[1][0], 18));
      console.log("Valuation USDT: ", formatUnits(totvals[1][1], 18));
      console.log("Valuation WETH: ", formatUnits(totvals[1][2], 18));
      console.log("Valuation WBTC: ", formatUnits(totvals[1][3], 18));

      console.log(
        "📊 Reserves After Batch Swap: ",
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8),
      );

      console.log("⚖️ Performing Rebalance 3 ⚖️");

      await pool.rebalanceWeights(await owner.getAddress());

      totvals = await pool.computeTotalValuation();
      console.log("Total Valuation: ", formatUnits(totvals[0], 18));
      console.log("Valuation USDC: ", formatUnits(totvals[1][0], 18));
      console.log("Valuation USDT: ", formatUnits(totvals[1][1], 18));
      console.log("Valuation WETH: ", formatUnits(totvals[1][2], 18));
      console.log("Valuation WBTC: ", formatUnits(totvals[1][3], 18));

      reservesAfter = await pool.getReserves();

      console.log(
        "📊 Reserves After Rebalance 3: ",
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8),
      );

      deviation = await pool.getDeviation();
      console.log("📉 Deviation after Rebalance 3: ", deviation.toString());

      console.log("⚖️ Performing Rebalance 4 ⚖️");

      await pool.rebalanceWeights(await owner.getAddress());

      reservesAfter = await pool.getReserves();

      console.log(
        "📊 Reserves After Rebalance 4: ",
        formatUnits(reservesAfter[0], 6),
        formatUnits(reservesAfter[1], 6),
        formatUnits(reservesAfter[2], 18),
        formatUnits(reservesAfter[3], 8),
      );

      deviation = await pool.getDeviation();
      console.log("📉 Deviation after Rebalance 4: ", deviation.toString());
    });
  });
});
