/* eslint-disable @typescript-eslint/no-unused-vars */

import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers, upgrades } from 'hardhat'
import erc20ABI from '../abis/common/ERC20.json'

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */

/// Deploy -----------------------------------------------------------------------
const USDC = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174'
const WNATIVE = '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270'
const USDT = '0xc2132d05d31c914a87c6611c10748aeb04b58e8f'
const AAVE = '0xc2132d05d31c914a87c6611c10748aeb04b58e8f'
const WBTC = '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6'
const LINK = '0x53e0bca35ec356bd5dddfebbd1fc0fd03fabad39'
const WETH = '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619'
const _1INCHSPOTAGG = '0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8' // 1inch Spot Aggregator
const uniswapRouter = '0xE592427A0AEce92De3Edee1F18E0157C05861564'
const uniswapFactory = '0x1F98431c8aD98523631AE4a59f267346ea31F984'

const staticOracle = '0xB210CE856631EeEB767eFa666EC7C1C57738d438'

const upgradeProtocol: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /// Deployment ---------------------------------------------------------------------
  ///---------------------------------------------------------------------------------
  const { deployer } = await hre.getNamedAccounts()
  const { deploy } = hre.deployments
  const accounts = await hre.getUnnamedAccounts()
  const signer = await ethers.getSigner(deployer)

  // const BaluniV1AgentFactory = await ethers.getContractFactory("BaluniV1AgentFactory");
  // const agentFactory = await upgrades.upgradeProxy("0x48c3C00d1E181326da2AA4ea372882dB012F2DA0", BaluniV1AgentFactory);
  // const instanceAgentFactory = await agentFactory?.waitForDeployment();
  // console.log("BaluniV1AgentFactory upgraded to:", instanceAgentFactory.target);
  // await instanceAgentFactory.changeImplementation();

  /*  const BaluniV1Registry = await ethers.getContractFactory('BaluniV1Registry')
  await upgrades.prepareUpgrade(registry, BaluniV1Registry)
  const _registry = await upgrades.upgradeProxy(registry, BaluniV1Registry, {
    kind: 'uups',
  })
  const instanceRegistry = await _registry?.waitForDeployment()
  console.log('BaluniV1Registry upgraded to:', await _registry.getAddress())

  await instanceRegistry.setStaticOracle('0xB210CE856631EeEB767eFa666EC7C1C57738d438') */

  /* const BaluniV1Rebalancer = await ethers.getContractFactory('BaluniV1Rebalancer')
  await upgrades.prepareUpgrade('0x9273120cd27226B55b2438CeC06E624163AeeFb1', BaluniV1Rebalancer)
  const rebalancer = await upgrades.upgradeProxy('0x9273120cd27226B55b2438CeC06E624163AeeFb1', BaluniV1Rebalancer, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['0xCF4d4CCfE28Ef12d4aCEf2c9F5ebE6BE72Abe182', 21],
    },
  })
  const instanceRebalancer = await rebalancer?.waitForDeployment()
  console.log('BaluniV1Rebalancer upgraded to:', instanceRebalancer.target) */

  /* const BaluniV1Swapper = await ethers.getContractFactory('BaluniV1Swapper')
  await upgrades.prepareUpgrade('0xfd308a0bE8c5a682F61aA0f01Cbb704a7A33AB7c', BaluniV1Swapper)
  const swapper = await upgrades.upgradeProxy('0xfd308a0bE8c5a682F61aA0f01Cbb704a7A33AB7c', BaluniV1Swapper, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['0xCF4d4CCfE28Ef12d4aCEf2c9F5ebE6BE72Abe182', 10],
    },
  })
  await swapper?.waitForDeployment()
  console.log('BaluniV1Swapper upgraded to:', swapper.target) */

  /* const BaluniV1PoolPeriphery = await ethers.getContractFactory('BaluniV1PoolPeriphery')
  await upgrades.prepareUpgrade('0xBE099A2a4240b95042c7aAaF8A52a2780f68a2E6', BaluniV1PoolPeriphery)
  const baluniPeriphery = await upgrades.upgradeProxy(
    '0xBE099A2a4240b95042c7aAaF8A52a2780f68a2E6',
    BaluniV1PoolPeriphery,
    {
      kind: 'uups',
      call: {
        fn: 'reinitialize',
        args: [registry, 6],
      },
    }
  )
  const instancePeriphery = await baluniPeriphery?.waitForDeployment()
  console.log('BaluniV1Periphery upgraded to:', instancePeriphery.target) */

  const BaluniV1AgentFactory = await ethers.getContractFactory('BaluniV1AgentFactory')
  await upgrades.prepareUpgrade('0xCa1C2a003e33223cF5356E8ecA99561DC40904f9', BaluniV1AgentFactory)
  const baluniAgentFactory = await upgrades.upgradeProxy(
    '0xCa1C2a003e33223cF5356E8ecA99561DC40904f9',
    BaluniV1AgentFactory,
    {
      kind: 'uups',
      call: {
        fn: 'reinitialize',
        args: ['0x9eD5C2c3a0d1B68c659e053Bd5B47829C1BaE60F', 3],
      },
    }
  )
  await baluniAgentFactory?.waitForDeployment()
  console.log('BaluniV1AgentFactory upgraded to:', baluniAgentFactory.target)
  /* const BaluniV1Oracle = await ethers.getContractFactory('BaluniV1Oracle')
  await upgrades.prepareUpgrade('0x3Ad437171b054FD16c013ec7f62254C052A0DCE7', BaluniV1Oracle)
  const baluniOracle = await upgrades.upgradeProxy('0x3Ad437171b054FD16c013ec7f62254C052A0DCE7', BaluniV1Oracle, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['0xCF4d4CCfE28Ef12d4aCEf2c9F5ebE6BE72Abe182', 14],
    },
  })
  await baluniOracle?.waitForDeployment()
  console.log('BaluniV1Oracle upgraded to:', baluniOracle.target) */

  /*   const BaluniV1Router = await ethers.getContractFactory('BaluniV1Router')
  await upgrades.prepareUpgrade('0xEd1B284de8D6B398B5744F5178E8BE198A4DaF5e', BaluniV1Router)
  const baluniRouter = await upgrades.upgradeProxy('0xEd1B284de8D6B398B5744F5178E8BE198A4DaF5e', BaluniV1Router, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['0xCF4d4CCfE28Ef12d4aCEf2c9F5ebE6BE72Abe182', 8],
    },
  })
  await baluniRouter?.waitForDeployment()
  console.log('BaluniV1Router upgraded to:', baluniRouter.target) */

  // const BaluniV1PoolFactory = await ethers.getContractFactory("BaluniV1PoolFactory");
  // await upgrades.prepareUpgrade(factoryAddress, BaluniV1PoolFactory);
  // const baluniPoolFactory = await upgrades.upgradeProxy(factoryAddress, BaluniV1PoolFactory, {
  //   kind: "uups",
  //   call: {
  //     fn: "reinitialize",
  //     args: [4],
  //   },
  // });
  // const instanceFactory = await baluniPoolFactory?.waitForDeployment();
  // console.log("BaluniV1PoolFactory upgraded to:", instanceFactory.target);

  // const pool = await deploy("BaluniV1Pool", {
  //   from: deployer,
  //   args: [],
  //   log: true,
  //   autoMine: true,
  // });

  // // wait 5 second
  // await new Promise(resolve => setTimeout(resolve, 5000));

  // // Creare l'interfaccia ABI corretta per la funzione reinitialize
  // const abi = [
  //   "function reinitialize(address _rebalancer, address[] memory _assets, uint256[] memory _weights, uint256 _trigger, uint64 _version)",
  // ];

  // const iface = new ethers.Interface(abi);

  // // Codificare i dati della funzione reinitialize
  // const callData = iface.encodeFunctionData("reinitialize", [
  //   "0x1CC8A760bb5d714E3290a30044c6f4f4cEc01dac",
  //   [USDT, USDC],
  //   [500, 500],
  //   500,
  //   2,
  // ]);

  // await instanceFactory.upgradePoolImplementationAndReinitialize(
  //   "0xeB80b53Ad23f82a1288ca732105339Eac2E96f8f",
  //   pool.address,
  //   callData,
  // );

  // const BaluniV1MarketOracle = await ethers.getContractFactory("BaluniV1MarketOracle");
  // //await upgrades.forceImport("0x786f9A343c58573ae32d8ca74bC7a67A0920aD84", BaluniV1MarketOracle);
  // const baluniMarketOracle = await upgrades.upgradeProxy(
  //   "0x786f9A343c58573ae32d8ca74bC7a67A0920aD84",
  //   BaluniV1MarketOracle,
  // );
  // const instanceMarketOracle = await baluniMarketOracle?.waitForDeployment();
  // console.log("BaluniV1MarketOracle upgraded to:", instanceMarketOracle.target);

  // UPDATE BALUNI POOL
  //   const BaluniV1Pool = await ethers.getContractFactory("BaluniV1Pool");
  //   await upgrades.prepareUpgrade("0x3dfbeCEeA8A1e7A358B24880d814457506bdB86a", BaluniV1Pool);
  //   await upgrades.forceImport("0x3dfbeCEeA8A1e7A358B24880d814457506bdB86a", BaluniV1Pool);
  //   const pool = await upgrades.upgradeProxy("0x3dfbeCEeA8A1e7A358B24880d814457506bdB86a", BaluniV1Pool, {
  //     kind: "uups",
  //     call: {
  //       fn: "reinitialize",
  //       args: ["0x1CC8A760bb5d714E3290a30044c6f4f4cEc01dac", [USDT, USDC], [5000, 5000], 500, 4],
  //     },
  //   });
  //   const intancePool = await pool?.waitForDeployment();
  //   console.log("BaluniV1Pool upgraded to:", intancePool.target);
}

export default upgradeProtocol

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
upgradeProtocol.tags = ['upgrades']
