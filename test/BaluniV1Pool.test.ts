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

    // Deploy Mock Rebalancer
    const MockRebalancer = await hre.ethers.getContractFactory("MockRebalancer");
    rebalancer = (await MockRebalancer.deploy(
      await usdt.getAddress(),
      await usdc.getAddress(),
      await wmatic.getAddress(),
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

    // Create a new pool
    await factory.createPool([await usdc.getAddress(), await usdt.getAddress()], [6000, 4000], 10000);
    const poolAddress = await factory.getPoolByAssets(await usdc.getAddress(), await usdt.getAddress());
    pool = (await ethers.getContractAt("BaluniV1Pool", poolAddress)) as BaluniV1Pool;

    await rebalancer.setTreasury(await owner.getAddress());
  });

  describe("Minting and Burn", function () {
    it("should mint LP tokens correctly", async function () {
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits("6000", 6));
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits("4000", 6));

      console.log("USDC Balance:", formatUnits(await usdc.balanceOf(await owner.getAddress()), 6));
      console.log("USDT Balance:", formatUnits(await usdt.balanceOf(await owner.getAddress()), 6));

      await periphery.addLiquidity(
        [ethers.parseUnits("6000", 6), ethers.parseUnits("4000", 6)],
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

      console.log("USDC Balance:", formatUnits(await usdc.balanceOf(await owner.getAddress()), 6));
      console.log("USDT Balance:", formatUnits(await usdt.balanceOf(await owner.getAddress()), 6));
    });
  });

  describe("Swapping", function () {
    it("should swap USDC to USDT correctly using periphery", async function () {
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits("6000", 6));
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits("4000", 6));

      await periphery.addLiquidity(
        [ethers.parseUnits("6000", 6), ethers.parseUnits("4000", 6)],
        await pool.getAddress(),
        await owner.getAddress(),
      );

      await usdc.transfer(await addr1.getAddress(), ethers.parseUnits("100", 6));
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.parseUnits("100", 6));

      await periphery
        .connect(addr1)
        .swap(await usdc.getAddress(), await usdt.getAddress(), ethers.parseUnits("100", 6), await addr1.getAddress());
      const usdtBalance = await usdt.balanceOf(await addr1.getAddress());

      console.log("USDT Balance: ", ethers.formatUnits(usdtBalance.toString(), 6));
      expect(usdtBalance).to.be.gt(ethers.parseUnits("99", 6));
    });
  });

  describe("Swapping and Rebalance", function () {
    it("should swap USDC to USDT correctly using periphery and rebalance the pool", async function () {
      await usdc.approve(await periphery.getAddress(), ethers.parseUnits("6000", 6));
      await usdt.approve(await periphery.getAddress(), ethers.parseUnits("4000", 6));
      await periphery.addLiquidity(
        [ethers.parseUnits("6000", 6), ethers.parseUnits("4000", 6)],
        await pool.getAddress(),
        await owner.getAddress(),
      );

      await usdc.transfer(await addr1.getAddress(), ethers.parseUnits("2000", 6));
      usdc.connect(addr1).approve(await periphery.getAddress(), ethers.parseUnits("2000", 6));

      const reservesB4Swap = await pool.getReserves();
      console.log("Reserves: ", formatUnits(reservesB4Swap[0], 6), formatUnits(reservesB4Swap[1], 6));

      await periphery
        .connect(addr1)
        .swap(await usdc.getAddress(), await usdt.getAddress(), ethers.parseUnits("2000", 6), await addr1.getAddress());

      const usdtBalance = await usdt.balanceOf(await addr1.getAddress());
      let usdtOwnerBalance = await usdt.balanceOf(await owner.getAddress());

      let deviation = await pool.getDeviation();
      console.log("Deviation: ", deviation.toString());

      console.log("USDT Balance: ", ethers.formatUnits(usdtBalance.toString(), 6));
      console.log("USDT Owner Balance: ", ethers.formatUnits(usdtOwnerBalance.toString(), 6));
      expect(usdtBalance).to.be.gt(ethers.parseUnits("1900", 6));

      const reservesBefore = await pool.getReserves();
      console.log("Reserves Before: ", formatUnits(reservesBefore[0], 6), formatUnits(reservesBefore[1], 6));

      await usdc.approve(await pool.getAddress(), ethers.MaxUint256);
      await usdt.approve(await pool.getAddress(), ethers.MaxUint256);

      await pool.rebalanceWeights(await owner.getAddress());

      let reservesAfter = await pool.getReserves();
      console.log("Reserves After: ", formatUnits(reservesAfter[0], 6), formatUnits(reservesAfter[1], 6));

      let realBalances = await pool.getRealBalances();
      console.log("Real Balances: ", formatUnits(realBalances[0], 6), formatUnits(realBalances[1], 6));

      let exededAmount = await pool.getExcessAmounts();
      console.log("Exceeded Amount: ", formatUnits(exededAmount[0], 6), formatUnits(exededAmount[1], 6));

      deviation = await pool.getDeviation();
      console.log("Deviation: ", deviation.toString());

      await pool.rebalanceWeights(await owner.getAddress());

      reservesAfter = await pool.getReserves();
      console.log("Reserves After: ", formatUnits(reservesAfter[0], 6), formatUnits(reservesAfter[1], 6));

      realBalances = await pool.getRealBalances();
      console.log("Real Balances: ", formatUnits(realBalances[0], 6), formatUnits(realBalances[1], 6));

      exededAmount = await pool.getExcessAmounts();
      console.log("Exceeded Amount: ", formatUnits(exededAmount[0], 6), formatUnits(exededAmount[1], 6));

      deviation = await pool.getDeviation();
      console.log("Deviation: ", deviation.toString());

      await pool.rebalanceWeights(await owner.getAddress());

      reservesAfter = await pool.getReserves();
      console.log("Reserves After: ", formatUnits(reservesAfter[0], 6), formatUnits(reservesAfter[1], 6));

      realBalances = await pool.getRealBalances();
      console.log("Real Balances: ", formatUnits(realBalances[0], 6), formatUnits(realBalances[1], 6));

      exededAmount = await pool.getExcessAmounts();
      console.log("Exceeded Amount: ", formatUnits(exededAmount[0], 6), formatUnits(exededAmount[1], 6));

      deviation = await pool.getDeviation();
      console.log("Deviation: ", deviation.toString());

      await pool.rebalanceWeights(await owner.getAddress());

      reservesAfter = await pool.getReserves();
      console.log("Reserves After: ", formatUnits(reservesAfter[0], 6), formatUnits(reservesAfter[1], 6));

      deviation = await pool.getDeviation();
      console.log("Deviation: ", deviation.toString());

      usdtOwnerBalance = await usdt.balanceOf(await owner.getAddress());
      console.log("USDT Owner Balance: ", ethers.formatUnits(usdtOwnerBalance.toString(), 6));
    });
  });
});
