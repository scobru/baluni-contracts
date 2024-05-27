/* eslint-disable @typescript-eslint/no-unused-vars */
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
const _1INCHSPOTAGG = "0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8"; // 1inch Spot Aggregator
const uniswapRouter = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
const uniswapFactory = "0x1F98431c8aD98523631AE4a59f267346ea31F984";

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // const BaluniV1AgentFactory = await ethers.getContractFactory("BaluniV1AgentFactory");
  // const agentFactory = await upgrades.deployProxy(BaluniV1AgentFactory, {
  //   kind: "uups",
  // });
  // const instanceAgentFactory = await agentFactory?.waitForDeployment();
  // console.log("BaluniV1AgentFactory deployed to:", instanceAgentFactory.target);
  // const BaluniV1Router = await ethers.getContractFactory("BaluniV1Router");
  // const baluniRouter = await upgrades.deployProxy(
  //   BaluniV1Router,
  //   [USDC, WNATIVE, _1INCHSPOTAGG, uniswapRouter, uniswapFactory],
  //   {
  //     kind: "uups",
  //   },
  // );
  // const instanceRouter = await baluniRouter?.waitForDeployment();
  // console.log("BaluniV1Router deployed to:", instanceRouter.target);
  // const BaluniV1Rebalancer = await ethers.getContractFactory("BaluniV1Rebalancer");
  // const baluniRebalancer = await upgrades.deployProxy(
  //   BaluniV1Rebalancer,
  //   [instanceRouter.target, USDC, WNATIVE, uniswapRouter, uniswapFactory],
  //   { kind: "uups" },
  // );
  // const instanceRebalance = await baluniRebalancer?.waitForDeployment();
  // console.log("BaluniV1Rebalance deployed to:", instanceRebalance.target);
  // console.log("Change Router in Agent Factory");
  // await instanceAgentFactory.changeRouter(instanceRouter.target);
  // console.log("Set Agent Factory in Router");
  // await instanceRouter.changeAgentFactory(instanceAgentFactory.target);
  // const BaluniV1MarketOracle = await ethers.getContractFactory("BaluniV1MarketOracle");
  // const baluniOracle = await upgrades.deployProxy(BaluniV1MarketOracle, {
  //   kind: "uups",
  // });
  // const instanceOracle = await baluniOracle?.waitForDeployment();
  // console.log("BaluniV1MarketOracle deployed to:", instanceOracle.target);
  // Others ---------------------------------------------------------------------------------
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

deployYourContract.tags = ["deploy-protocol"];
