import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers, upgrades } from "hardhat";

import erc20ABI from "../abis/common/ERC20.json";
/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
/// Deploy -----------------------------------------------------------------------
const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
const WNATIVE = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270";
const USDT = "0xc2132d05d31c914a87c6611c10748aeb04b58e8f";
const oracle = "0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8"; // 1inch Spot Aggregator
const uniswapRouter = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
const uniswapFactory = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const staticOracle = "0xB210CE856631EeEB767eFa666EC7C1C57738d438";

const AggUSDTUSD = "0x0A6513e40db6EB1b165753AD52E80663aeA50545";

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /// Deployment ---------------------------------------------------------------------
  ///---------------------------------------------------------------------------------

  const { deployer } = await hre.getNamedAccounts();
  // const { deploy } = hre.deployments;
  // const accounts = await hre.getUnnamedAccounts();

  const signer = await ethers.getSigner(deployer);

  // const BaluniV1AgentFactory = await ethers.getContractFactory("BaluniV1AgentFactory");
  // const agentFactory = await upgrades.deployProxy(BaluniV1AgentFactory, {
  //   kind: "uups",
  // });

  // const instanceAgentFactory = await agentFactory?.waitForDeployment();
  // console.log("BaluniV1AgentFactory deployed to:", instanceAgentFactory.target);

  // const BaluniV1Router = await ethers.getContractFactory("BaluniV1Router");
  // const baluniRouter = await upgrades.deployProxy(
  //   BaluniV1Router,
  //   [USDC, WNATIVE, oracle, uniswapRouter, uniswapFactory],
  //   {
  //     kind: "uups",
  //   },
  // );

  // const instanceRouter = await baluniRouter?.waitForDeployment();
  // console.log("BaluniV1Router deployed to:", instanceRouter.target);

  // const BaluniV1Rebalancer = await ethers.getContractFactory("BaluniV1Rebalancer");
  // const baluniRebalancer = await upgrades.deployProxy(
  //   BaluniV1Rebalancer,
  //   ["0x8DD108DDC24A6b07Bc9191DE5f0337f240c4e0c0", USDC, WNATIVE, uniswapRouter, uniswapFactory],
  //   { kind: "uups" },
  // );

  // const instanceRebalance = await baluniRebalancer?.waitForDeployment();
  // console.log("BaluniV1Rebalance deployed to:", instanceRebalance.target);

  // console.log("Change Router in Agent Factory");
  // await instanceAgentFactory.changeRouter(instanceRouter.target);

  // console.log("Set Agent Factory in Router");
  // await instanceRouter.changeAgentFactory(instanceAgentFactory.target);

  // const BaluniV1PoolFactory = await ethers.getContractFactory("BaluniV1PoolFactory");
  // const baluniV1PoolFactory = await upgrades.deployProxy(BaluniV1PoolFactory, [], { kind: "uups" });
  // const instancePoolFactory = await baluniV1PoolFactory?.waitForDeployment();
  // console.log("BaluniV1PoolFactory deployed to:", instancePoolFactory.target);
  // await instancePoolFactory.createPool(AggUSDTUSD, "0x1CC8A760bb5d714E3290a30044c6f4f4cEc01dac", USDT, USDC);

  // const BaluniV1PoolPeriphery = await ethers.getContractFactory("BaluniV1PoolPeriphery");
  // const baluniV1PoolPeriphery = await upgrades.deployProxy(
  //   BaluniV1PoolPeriphery,
  //   [instancePoolFactory.target], // PoolFactory
  //   {
  //     kind: "uups",
  //   },
  // );
  // const instancePoolPeriphery = await baluniV1PoolPeriphery?.waitForDeployment();
  // console.log("BaluniV1PoolPeriphery deployed to:", instancePoolPeriphery.target);

  // const poolAdress = await instancePoolFactory.allPools(0);
  // console.log("Pool USDT-USDC deployed to:", poolAdress);

  // const BaluniV1MarketOracle = await ethers.getContractFactory("BaluniV1MarketOracle");
  // const baluniOracle = await upgrades.deployProxy(BaluniV1PoolPeriphery], {
  //   kind: "uups",
  // });

  // const instanceOracle = await baluniOracle?.waitForDeployment();
  // console.log("BaluniV1MarketOracle deployed to:", instanceOracle.target);

  // console.log("CHange Markt Oracle in Router");
  // await instanceRouter.changeMarketOracle(instanceOracle.target);

  // Approvals
  // console.log("Approve USDC to Pool");
  // const _USDC = new ethers.Contract("0x2791bca1f2de4661ed88a30c99a7a9449aa84174", erc20ABI, signer);
  // await _USDC.approve(poolAdress, ethers.MaxUint256);
  // console.log("Approve USDT to Pool");
  // const _USDT = new ethers.Contract("0xc2132d05d31c914a87c6611c10748aeb04b58e8f", erc20ABI, signer);
  // await _USDT.approve(poolAdress, ethers.MaxUint256);
  // console.log("Approve USDC to Periphery");
  // await _USDC.approve(instancePoolPeriphery.target, ethers.MaxUint256);
  // console.log("Approve USDT to Periphery");
  // await _USDT.approve(instancePoolPeriphery.target, ethers.MaxUint256);

  /// Upgrades -----------------------------------------------------------------------
  ///---------------------------------------------------------------------------------

  // const BaluniV1AgentFactory = await ethers.getContractFactory("BaluniV1AgentFactory");
  // const agentFactory = await upgrades.upgradeProxy("0x48c3C00d1E181326da2AA4ea372882dB012F2DA0", BaluniV1AgentFactory);
  // const instanceAgentFactory = await agentFactory?.waitForDeployment();
  // console.log("BaluniV1AgentFactory upgraded to:", instanceAgentFactory.target);
  // await instanceAgentFactory.changeImplementation();

  const BaluniV1Router = await ethers.getContractFactory("BaluniV1Router");
  //await upgrades.forceImport("0x8DD108DDC24A6b07Bc9191DE5f0337f240c4e0c0", BaluniV1Router);
  const router = await upgrades.upgradeProxy("0x8DD108DDC24A6b07Bc9191DE5f0337f240c4e0c0", BaluniV1Router, {
    kind: "uups",
    call: {
      fn: "reinitialize",
      args: [USDC, WNATIVE, oracle, uniswapRouter, uniswapFactory, "0x1CC8A760bb5d714E3290a30044c6f4f4cEc01dac", 7],
    },
  });
  const instanceRouter = await router?.waitForDeployment();
  console.log("BaluniV1Router upgraded to:", instanceRouter.target);

  // const BaluniV1Rebalancer = await ethers.getContractFactory("BaluniV1Rebalancer");
  // //await upgrades.forceImport("0x1CC8A760bb5d714E3290a30044c6f4f4cEc01dac", BaluniV1Rebalancer);
  // const rebalancer = await upgrades.upgradeProxy("0x1CC8A760bb5d714E3290a30044c6f4f4cEc01dac", BaluniV1Rebalancer, {
  //   kind: "uups",
  //   call: {
  //     fn: "reinitialize",
  //     args: ["0x8DD108DDC24A6b07Bc9191DE5f0337f240c4e0c0", USDC, WNATIVE, uniswapRouter, uniswapFactory, 35],
  //   },
  // });
  // const instanceRebalancer = await rebalancer?.waitForDeployment();
  // console.log("BaluniV1Rebalancer upgraded to:", instanceRebalancer.target);

  // const BaluniV1Pool = await ethers.getContractFactory("BaluniV1Pool");
  // await upgrades.forceImport("0xB2D1770CAAC3D5773BE8B18dA095d8E1ABeA1A0E", BaluniV1Pool);
  // const baluniPool = await upgrades.upgradeProxy("0xB2D1770CAAC3D5773BE8B18dA095d8E1ABeA1A0E", BaluniV1Pool, {
  //   kind: "uups",
  //   /* call: {
  //     fn: "reinitialize",
  //     args: [AggUSDTUSD, "0x1CC8A760bb5d714E3290a30044c6f4f4cEc01dac", USDT, USDC, 20],
  //   }, */
  // });
  // const instancePool = await baluniPool?.waitForDeployment();
  // console.log("BaluniV1Pool upgraded to:", instancePool.target);

  // const BaluniV1PoolPeriphery = await ethers.getContractFactory("BaluniV1PoolPeriphery");
  // await upgrades.forceImport("0x253C88D11Cf2645BE84D0446000A874B12b656d6", BaluniV1PoolPeriphery);
  // const baluniPeriphery = await upgrades.upgradeProxy("0x253C88D11Cf2645BE84D0446000A874B12b656d6", BaluniV1Periphery, {
  //   kind: "uups",
  //   call: {
  //     fn: "reinitialize",
  //     args: ["0x377A08B8A4eB152454Db9386441832A09A06bb3F", 3],
  //   },
  // });
  // const instancePeriphery = await baluniPeriphery?.waitForDeployment();
  // console.log("BaluniV1Periphery upgraded to:", instancePeriphery.target);

  // const BaluniV1PoolFactory = await ethers.getContractFactory("BaluniV1PoolFactory");
  // await upgrades.forceImport("0x6D059183aa33198476C2D19A056AD1D9e8D3FeE1", BaluniV1PoolFactory);
  // const baluniPoolFactory = await upgrades.upgradeProxy(
  //   "0x6D059183aa33198476C2D19A056AD1D9e8D3FeE1",
  //   BaluniV1PoolFactory,
  //   {
  //     kind: "uups",
  //     call: {
  //       fn: "reinitialize",
  //       args: [2],
  //     },
  //   },
  // );
  // const instanceFactory = await baluniPoolFactory?.waitForDeployment();
  // console.log("BaluniV1PoolFactory upgraded to:", instanceFactory.target);

  // const BaluniV1MarketOracle = await ethers.getContractFactory("BaluniV1MarketOracle");
  // //await upgrades.forceImport("0x786f9A343c58573ae32d8ca74bC7a67A0920aD84", BaluniV1MarketOracle);
  // const baluniMarketOracle = await upgrades.upgradeProxy(
  //   "0x786f9A343c58573ae32d8ca74bC7a67A0920aD84",
  //   BaluniV1MarketOracle,
  // );
  // const instanceMarketOracle = await baluniMarketOracle?.waitForDeployment();
  // console.log("BaluniV1MarketOracle upgraded to:", instanceMarketOracle.target);

  //
  // Others ---------------------------------------------------------------------------------

  // const router = await deploy("BaluniRouter", {
  //   from: deployer,
  //   // Contract constructor arguments
  //   args: [],
  //   log: true,
  //   autoMine: true,
  // });
  // console.log("router:", router.address);
  // const testRouter = await deploy("TestBaluniRouter", {
  //   from: deployer,
  //   // Contract constructor arguments
  //   args: [],
  //   log: true,
  //   autoMine: true,
  // });
  // console.log("testRouter:", testRouter.address);

  // const oracle = await deploy("Oracle", {
  //   from: deployer,
  //   // Contract constructor arguments
  //   args: ["0xAB594600376Ec9fD91F8e885dADF0CE036862dE0"],
  //   log: true,
  //   // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
  //   // automatically mining the contract deployment transaction. There is no effect on live networks.
  //   autoMine: true,
  // });

  // console.log("oracle:", oracle.address);

  // const pool = await deploy("Pool", {
  //   from: deployer,
  //   // Contract constructor arguments
  //   args: [oracle.address, "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270", "0x28F53bA70E5c8ce8D03b1FaD41E9dF11Bb646c36"],
  //   log: true,
  //   // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
  //   // automatically mining the contract deployment transaction. There is no effect on live networks.
  //   autoMine: true,
  // });

  // console.log("pool:", pool.address);

  // const tournament = await deploy("Tournament", {
  //   from: deployer,
  //   // Contract constructor arguments
  //   args: [oracle.address, 50],
  //   log: true,
  //   // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
  //   // automatically mining the contract deployment transaction. There is no effect on live networks.
  //   autoMine: true,
  // });

  // console.log("tournament:", tournament.address);
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["BaluniRouter"];
