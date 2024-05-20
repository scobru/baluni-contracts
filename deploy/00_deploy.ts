import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers, upgrades } from "hardhat";

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

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;
  const accounts = await hre.getUnnamedAccounts();

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
  //   [instanceRouter.target, USDC, WNATIVE, oracle, uniswapRouter, uniswapFactory],
  //   { kind: "uups" },
  // );
  // const instanceRebalance = await baluniRebalancer?.waitForDeployment();
  // console.log("BaluniV1Rebalance deployed to:", instanceRebalance.target);

  // console.log("Change Router in Agent Factory");
  // await instanceAgentFactory.changeRouter(instanceRouter.target);

  // console.log("Set Agent Factory in Router");
  // await instanceRouter.changeAgentFactory(instanceAgentFactory.target);

  // const BaluniV1StablePool = await ethers.getContractFactory("BaluniV1Pool");
  // const baluniV1StablePool = await upgrades.deployProxy(
  //   BaluniV1StablePool,
  //   [oracle, instanceRebalance.target, USDT, USDC],
  //   { kind: "uups" },
  // );
  // const instanceStablePool = await baluniV1StablePool?.waitForDeployment();
  // console.log("BaluniV1tablePool deployed to:", instanceStablePool.target);

  /*  const BaluniV1MarketOracle = await ethers.getContractFactory("BaluniV1MarketOracle");
  const baluniOracle = await upgrades.deployProxy(
    BaluniV1MarketOracle,
    ["0x631E566f96DAAccfFFC2A1846Bd6D3cfA80D5684", USDC, staticOracle],
    {
      kind: "uups",
    },
  );
  const instanceOracle = await baluniOracle?.waitForDeployment();
  console.log("BaluniV1MarketOracle deployed to:", instanceOracle.target); */

  /// Upgrades -----------------------------------------------------------------------

  // const BaluniV1AgentFactory = await ethers.getContractFactory("BaluniV1AgentFactory");
  // const agentFactory = await upgrades.upgradeProxy("0x48c3C00d1E181326da2AA4ea372882dB012F2DA0", BaluniV1AgentFactory);
  // const instanceAgentFactory = await agentFactory?.waitForDeployment();
  // console.log("BaluniV1AgentFactory upgraded to:", instanceAgentFactory.target);
  // await instanceAgentFactory.changeImplementation();

  const BaluniV1Router = await ethers.getContractFactory("BaluniV1Router");
  //await upgrades.forceImport("0x631E566f96DAAccfFFC2A1846Bd6D3cfA80D5684", BaluniV1Router);
  const router = await upgrades.upgradeProxy("0x631E566f96DAAccfFFC2A1846Bd6D3cfA80D5684", BaluniV1Router);
  const instanceRouter = await router?.waitForDeployment();
  console.log("BaluniV1Router upgraded to:", instanceRouter.target);

  // const BaluniV1Rebalancer = await ethers.getContractFactory("BaluniV1Rebalancer");
  // const rebalancer = await upgrades.upgradeProxy("0x7Ed16f194faCD6eAaB72cdd847b2bEcc13C240EC", BaluniV1Rebalancer);
  // const instanceRebalancer = await rebalancer?.waitForDeployment();
  // console.log("BaluniV1Rebalancer upgraded to:", instanceRebalancer.target);

  // const BaluniV1StablePool = await ethers.getContractFactory("BaluniV1Pool");
  // const baluniStablePool = await upgrades.upgradeProxy(
  //   "0x56fDcF3B78d3dbC06e90b369F95abe0008c1cC5E",
  //   BaluniV1StablePool,
  // );
  // const instanceStablePool = await baluniStablePool?.waitForDeployment();
  // console.log("BaluniV1StablePool upgraded to:", instanceStablePool.target);

  /* const BaluniV1MarketOracle = await ethers.getContractFactory("BaluniV1MarketOracle");
  //await upgrades.forceImport("0x786f9A343c58573ae32d8ca74bC7a67A0920aD84", BaluniV1MarketOracle);
  const baluniMarketOracle = await upgrades.upgradeProxy(
    "0x786f9A343c58573ae32d8ca74bC7a67A0920aD84",
    BaluniV1MarketOracle,
  );
  const instanceMarketOracle = await baluniMarketOracle?.waitForDeployment();
  console.log("BaluniV1MarketOracle upgraded to:", instanceMarketOracle.target); */

  /* const baluniStablePool = await deploy("BaluniV1StablePool", {
    from: deployer,
    // Contract constructor arguments
    args: [oracle, "0x7Ed16f194faCD6eAaB72cdd847b2bEcc13C240EC", USDT, USDC],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  }); 
  console.log("baluniStablePool:", baluniStablePool.address); */

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

  /* const oracle = await deploy("Oracle", {
    from: deployer,
    // Contract constructor arguments
    args: ["0xAB594600376Ec9fD91F8e885dADF0CE036862dE0"],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  console.log("oracle:", oracle.address);

  const pool = await deploy("Pool", {
    from: deployer,
    // Contract constructor arguments
    args: [oracle.address, "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270", "0x28F53bA70E5c8ce8D03b1FaD41E9dF11Bb646c36"],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  console.log("pool:", pool.address);

  const tournament = await deploy("Tournament", {
    from: deployer,
    // Contract constructor arguments
    args: [oracle.address, 50],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  console.log("tournament:", tournament.address); */
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["BaluniRouter"];
