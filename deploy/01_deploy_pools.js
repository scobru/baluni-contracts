"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const hardhat_1 = require("hardhat");
/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
/// Deploy -----------------------------------------------------------------------
const USDC = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';
const WNATIVE = '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270';
const USDT = '0xc2132d05d31c914a87c6611c10748aeb04b58e8f';
const WBTC = '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6';
const WETH = '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619';
const oldRebalancer = '0x4A702645Fc5CcFa1E337f8DAaF3f14d96Fd3595b';
const deployPools = async function (hre) {
    const signers = await hre.ethers.getSigners();
    const BaluniV1PoolFactory = await hardhat_1.ethers.getContractFactory('BaluniV1PoolFactory');
    const baluniV1PoolFactory = await hardhat_1.upgrades.deployProxy(BaluniV1PoolFactory, [oldRebalancer], { kind: 'uups' });
    const instancePoolFactory = await baluniV1PoolFactory?.waitForDeployment();
    console.log('BaluniV1PoolFactory deployed to:', instancePoolFactory.target);
    // wait 5 second
    await new Promise((resolve) => setTimeout(resolve, 5000));
    const BaluniV1PoolPeriphery = await hardhat_1.ethers.getContractFactory('BaluniV1PoolPeriphery');
    const baluniV1PoolPeriphery = await hardhat_1.upgrades.deployProxy(BaluniV1PoolPeriphery, [await instancePoolFactory.getAddress()], // PoolFactory
    {
        kind: 'uups',
    });
    const instancePoolPeriphery = await baluniV1PoolPeriphery?.waitForDeployment();
    console.log('BaluniV1PoolPeriphery deployed to:', instancePoolPeriphery.target);
    console.log('Change periphery');
    instancePoolFactory.connect(signers[0]);
    await instancePoolFactory.changePeriphery(instancePoolPeriphery.target);
    await new Promise((resolve) => setTimeout(resolve, 10000));
    await instancePoolFactory.createPool([USDT, USDC], [5000, 5000], 500);
    await instancePoolFactory.createPool([WBTC, USDC, WETH], [5000, 3000, 2000], 500);
    await instancePoolFactory.createPool([WETH, USDC], [8000, 2000], 500);
    await instancePoolFactory.createPool([WNATIVE, USDC], [8000, 2000], 500);
};
exports.default = deployPools;
// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployPools.tags = ['deploy-pools'];
