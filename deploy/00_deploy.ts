import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers, upgrades } from "hardhat";
/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();

  // const accounts = await hre.getUnnamedAccounts();
  // const signer = await ethers.provider.getSigner(); // ottieni il signer

  // const BaluniV1AgentFactory = await ethers.getContractFactory("BaluniV1AgentFactory");
  // const agentFactory = await upgrades.deployProxy(BaluniV1AgentFactory, { kind: "uups" });

  // const instanceAgentFactory = await agentFactory?.waitForDeployment();
  // console.log("BaluniV1AgentFactory deployed to:", instanceAgentFactory.target);

  // const BaluniV1Router = await ethers.getContractFactory("BaluniV1Router");
  // const baluniRouter = await upgrades.deployProxy(BaluniV1Router, { kind: "uups" });

  // const instanceRouter = await baluniRouter?.waitForDeployment();
  // console.log("BaluniV1Router deployed to:", instanceRouter.target);

  // const BaluniV1RewardPool = await ethers.getContractFactory("BaluniV1RewardPool");
  // const baluniRewardPool = await upgrades.deployProxy(BaluniV1RewardPool, [instanceRouter.target], { kind: "uups" });

  // const instanceRewardPool = await baluniRewardPool?.waitForDeployment();
  // console.log("BaluniV1Reward deployed to:", instanceRewardPool.target);

  /* const BaluniV1Rebalancer = await ethers.getContractFactory("BaluniV1Rebalancer");
  const baluniRebalancer = await upgrades.deployProxy(
    BaluniV1Rebalancer,
    ["0xDf316b04aA2c05E02070FfaF4EB1E8E47C8E3176"],
    { kind: "uups" },
  );

  const instanceRebalance = await baluniRebalancer?.waitForDeployment();
  console.log("BaluniV1Rebalance deployed to:", instanceRebalance.target); */

  // console.log("Change Router in Agent Factory");

  // await instanceAgentFactory.changeRouter(instanceRouter.target);

  // console.log("Set Whitelist in Reward Pool");
  // await instanceRewardPool.setWhitelist(instanceRouter.target, true);

  // console.log("Set Agent Factory in Router");
  // await instanceRouter.changeAgentFactory(instanceAgentFactory.target);

  // console.log("Set RewardPool in Router");
  // await instanceRouter.changeRewardPool(instanceRewardPool.target);

  /// Upgrades -----------------------------------------------------------------------

  /* const BaluniV1AgentFactory = await ethers.getContractFactory("BaluniV1AgentFactory");
  const agentFactory = await upgrades.upgradeProxy("0x48c3C00d1E181326da2AA4ea372882dB012F2DA0", BaluniV1AgentFactory);
  const instanceAgentFactory = await agentFactory?.waitForDeployment();

  console.log("BaluniV1AgentFactory upgraded to:", instanceAgentFactory.target);
  await instanceAgentFactory.changeImplementation(); */

  /* const BaluniV1Router = await ethers.getContractFactory("BaluniV1Router");
  const router = await upgrades.upgradeProxy("0xDf316b04aA2c05E02070FfaF4EB1E8E47C8E3176", BaluniV1Router);
  const instanceRouter = await router?.waitForDeployment();
  console.log("BaluniV1Router upgraded to:", instanceRouter.target); */

  const BaluniV1Rebalancer = await ethers.getContractFactory("BaluniV1Rebalancer");
  const rebalancer = await upgrades.upgradeProxy("0x171af33387b8eA83702E9C895f374EDE8C7034CD", BaluniV1Rebalancer);
  const instanceRouter = await rebalancer?.waitForDeployment();
  console.log("BaluniV1Rebalancer upgraded to:", rebalancer.target);

  /* const BaluniV1RewardPool = await ethers.getContractFactory("BaluniV1RewardPool");
  const rewardPool = await upgrades.upgradeProxy("0x3Faa0B1703CB7f50E5333049d540F7E9FcEb0590", BaluniV1RewardPool);
  const instanceRewardPool = await rewardPool?.waitForDeployment();
  console.log("BaluniV1RewardPool upgraded to:", instanceRewardPool.target); */

  // const { deployer } = await hre.getNamedAccounts();
  // const { deploy } = hre.deployments;

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
