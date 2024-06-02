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
const _1INCHSPOTAGG = '0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8'; // 1inch Spot Aggregator
const uniswapRouter = '0xE592427A0AEce92De3Edee1F18E0157C05861564';
const uniswapFactory = '0x1F98431c8aD98523631AE4a59f267346ea31F984';
const USDT = '0xc2132d05d31c914a87c6611c10748aeb04b58e8f';
const WBTC = '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6';
const WETH = '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619';
const TREASURY = '0x0C01CDE1cCAcD1e47740F3728872Aeb7C69703C2';
const deployProtocol = async function (hre) {
    const BaluniV1Registry = await hardhat_1.ethers.getContractFactory('BaluniV1Registry');
    const baluniV1Registry = await hardhat_1.upgrades.deployProxy(BaluniV1Registry, [], { kind: 'uups' });
    const registry = await baluniV1Registry?.waitForDeployment();
    console.log('BaluniV1Registry deployed to:', registry.target);
    // set constnt
    await registry.setWNATIVE(WNATIVE);
    await registry.setUSDC(USDC);
    await registry.set1inchSpotAgg(_1INCHSPOTAGG);
    await registry.setTreasury(TREASURY);
    await registry.setUniswapFactory(uniswapFactory);
    await registry.setUniswapRouter(uniswapRouter);
    await registry.setBaluniRegistry(await registry.getAddress());
    const BaluniV1Swapper = await hardhat_1.ethers.getContractFactory('BaluniV1Swapper');
    const baluniSwapper = await hardhat_1.upgrades.deployProxy(BaluniV1Swapper, [await registry.getAddress()], {
        kind: 'uups',
    });
    const instanceSwapper = await baluniSwapper?.waitForDeployment();
    console.log('BaluniV1Swapper deployed to:', instanceSwapper.target);
    await registry.setBaluniSwapper(await instanceSwapper.target);
    const BaluniV1Oracle = await hardhat_1.ethers.getContractFactory('BaluniV1Oracle');
    const baluniOracle = await hardhat_1.upgrades.deployProxy(BaluniV1Oracle, [await registry.getAddress()], {
        kind: 'uups',
    });
    const instanceOracle = await baluniOracle?.waitForDeployment();
    console.log('BaluniV1Oracle deployed to:', instanceOracle.target);
    await registry.setBaluniOracle(await instanceOracle.target);
    const BaluniV1Rebalancer = await hardhat_1.ethers.getContractFactory('BaluniV1Rebalancer');
    const baluniRebalancer = await hardhat_1.upgrades.deployProxy(BaluniV1Rebalancer, [await registry.getAddress()], {
        kind: 'uups',
    });
    const instanceRebalance = await baluniRebalancer?.waitForDeployment();
    console.log('BaluniV1Rebalance deployed to:', instanceRebalance.target);
    await registry.setBaluniRebalancer(await instanceRebalance.target);
    const BaluniV1AgentFactory = await hardhat_1.ethers.getContractFactory('BaluniV1AgentFactory');
    const agentFactory = await hardhat_1.upgrades.deployProxy(BaluniV1AgentFactory, ['0xe4B9f8d8E52164F34450f1dFaC9B9b1B3c9FC448'], {
        kind: 'uups',
    });
    const instanceAgentFactory = await agentFactory?.waitForDeployment();
    console.log('BaluniV1AgentFactory deployed to:', instanceAgentFactory.target);
    await registry.setBaluniAgentFactory(await instanceAgentFactory.target);
    const BaluniV1Router = await hardhat_1.ethers.getContractFactory('BaluniV1Router');
    const baluniRouter = await hardhat_1.upgrades.deployProxy(BaluniV1Router, [await registry.getAddress()], {
        kind: 'uups',
    });
    const instanceRouter = await baluniRouter?.waitForDeployment();
    console.log('BaluniV1Router deployed to:', instanceRouter.target);
    await registry.setBaluniRouter(await instanceRouter.target);
    const BaluniV1PoolPeriphery = await hardhat_1.ethers.getContractFactory('BaluniV1PoolPeriphery');
    const baluniV1PoolPeriphery = await hardhat_1.upgrades.deployProxy(BaluniV1PoolPeriphery, [await registry.getAddress()], // PoolFactory
    {
        kind: 'uups',
    });
    const instancePoolPeriphery = await baluniV1PoolPeriphery?.waitForDeployment();
    console.log('BaluniV1PoolPeriphery deployed to:', instancePoolPeriphery.target);
    await registry.setBaluniPoolPeriphery(await instancePoolPeriphery.target);
    const BaluniV1PoolFactory = await hardhat_1.ethers.getContractFactory('BaluniV1PoolFactory');
    const baluniV1PoolFactory = await hardhat_1.upgrades.deployProxy(BaluniV1PoolFactory, [await registry.getAddress()], {
        kind: 'uups',
    });
    const instancePoolFactory = await baluniV1PoolFactory?.waitForDeployment();
    console.log('BaluniV1PoolFactory deployed to:', instancePoolFactory.target);
    await registry.setBaluniPoolFactory(await instancePoolFactory.target);
    await instancePoolFactory.createPool([USDT, USDC], [5000, 5000], 500);
    await instancePoolFactory.createPool([WBTC, USDC, WETH], [5000, 3000, 2000], 500);
    await instancePoolFactory.createPool([WETH, USDC], [8000, 2000], 500);
    await instancePoolFactory.createPool([WNATIVE, USDC], [8000, 2000], 500);
};
exports.default = deployProtocol;
deployProtocol.tags = ['deploy-protocol'];
