/* eslint-disable @typescript-eslint/no-unused-vars */

import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers, upgrades } from 'hardhat'
import erc20ABI from '../abis/common/ERC20.json'
import { getContract } from 'viem'

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */

/// Deploy -----------------------------------------------------------------------
const USDC = '0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359'
const WNATIVE = '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270'
const USDT = '0xc2132d05d31c914a87c6611c10748aeb04b58e8f'
const AAVE = '0xc2132d05d31c914a87c6611c10748aeb04b58e8f'
const WBTC = '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6'
const LINK = '0x53e0bca35ec356bd5dddfebbd1fc0fd03fabad39'
const WETH = '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619'
const _1INCHSPOTAGG = '0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8' // 1inch Spot Aggregator
const uniswapRouter = '0xE592427A0AEce92De3Edee1F18E0157C05861564'
const uniswapFactory = '0x1F98431c8aD98523631AE4a59f267346ea31F984'
const DAI = '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063'
const USDC_E = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174'

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

  /* const BaluniV1Registry = await ethers.getContractFactory('BaluniV1Registry')
  await upgrades.prepareUpgrade('0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', BaluniV1Registry)
  const _registry = await upgrades.upgradeProxy('0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', BaluniV1Registry, {
    kind: 'uups',
  })
  const instanceRegistry = await _registry?.waitForDeployment()
  console.log('BaluniV1Registry upgraded to:', await _registry.getAddress())
  await instanceRegistry.setBaluniVaultRegistry('0xa88161f82BAa0A065B1b3F785E85e6b5DB45E892') */

  /* const BaluniV1Rebalancer = await ethers.getContractFactory('BaluniV1Rebalancer')
  //await upgrades.forceImport('0x8c4eDC7a07B372606009E345017C2cB74d043578', BaluniV1Rebalancer)
  await upgrades.prepareUpgrade('0x8c4eDC7a07B372606009E345017C2cB74d043578', BaluniV1Rebalancer)
  const rebalancer = await upgrades.upgradeProxy('0x8c4eDC7a07B372606009E345017C2cB74d043578', BaluniV1Rebalancer, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', 34],
    }, 
  })
  const instanceRebalancer = await rebalancer?.waitForDeployment()
  console.log('BaluniV1Rebalancer upgraded to:', instanceRebalancer.target)  */

  /*  const BaluniV1Swapper = await ethers.getContractFactory('BaluniV1Swapper')
  await upgrades.prepareUpgrade('0x1d70473cF880341198C1909E236d29Afe2F220f8', BaluniV1Swapper)
  const swapper = await upgrades.upgradeProxy('0x1d70473cF880341198C1909E236d29Afe2F220f8', BaluniV1Swapper, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', 2],
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

  /*  const BaluniV1AgentFactory = await ethers.getContractFactory('BaluniV1AgentFactory')
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
  console.log('BaluniV1AgentFactory upgraded to:', baluniAgentFactory.target) */

  /* const BaluniV1Oracle = await ethers.getContractFactory('BaluniV1Oracle')
  await upgrades.prepareUpgrade('0xD8dDca643684e67c17087B7cF6CeE08C91F12511', BaluniV1Oracle)
  const baluniOracle = await upgrades.upgradeProxy('0xD8dDca643684e67c17087B7cF6CeE08C91F12511', BaluniV1Oracle, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', 21],
    },
  })
  await baluniOracle?.waitForDeployment()
  console.log('BaluniV1Oracle upgraded to:', baluniOracle.target)
 */

  /* const BaluniV1Router = await ethers.getContractFactory('BaluniV1Router')
  await upgrades.prepareUpgrade('0x8d7F211172bc11d7a99ad30026299e8ec508ACB0', BaluniV1Router)
  const baluniRouter = await upgrades.upgradeProxy('0x8d7F211172bc11d7a99ad30026299e8ec508ACB0', BaluniV1Router, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', 18],
    },
  })
  await baluniRouter?.waitForDeployment()
  console.log('BaluniV1Router upgraded to:', baluniRouter.target) */

  /* const BaluniV1Pool = await ethers.getContractFactory('BaluniV1Pool')
  await upgrades.prepareUpgrade('0x2abEf7D3eCA3074277534FfFfd994851Ac0092d3', BaluniV1Pool)
  const baluniPool = await upgrades.upgradeProxy('0x2abEf7D3eCA3074277534FfFfd994851Ac0092d3', BaluniV1Pool, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: [
        [USDC, USDC_E, USDT, DAI],
        [2500, 2500, 2500, 2500],
        100,
        "0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655",
        10 // baluni registry
      ]
    },
  })
  await baluniPool?.waitForDeployment()
  console.log('BaluniV1Pool upgraded to:', baluniPool.target) */

  /*   const BaluniV1Pool = await ethers.getContractFactory('BaluniV1Pool')
    await upgrades.prepareUpgrade('0xabEEAbbEaf1D160031e4BB2AC2918C8EeE73E9aa', BaluniV1Pool)
    const baluniPool = await upgrades.upgradeProxy('0xabEEAbbEaf1D160031e4BB2AC2918C8EeE73E9aa', BaluniV1Pool, {
      kind: 'uups',
      call: {
        fn: 'reinitialize',
        args: [
          [WBTC, WETH, USDC],
          [5000, 3000, 2000],
          100,
          "0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655",
          2 // baluni registry
        ]
      },
    })
    await baluniPool?.waitForDeployment()
    console.log('BaluniV1Pool upgraded to:', baluniPool.target) */

  //await upgrades.admin.transferProxyAdminOwnership('0x196D5479088Aada724119FBaE7B04a292cF6F0d3', '0x8aA5F726d9F868a21a8bd748E2f1E43bA31eb670')
  //await upgrades.admin.changeProxyAdmin('0x18F5429a422dA0B7c340A304212a49A02009aD36', '0x84F07be28ecd5b29Df340be8b065A6113a8e893e')

  // Get the current proxy admin address for the given proxy address
  /* const BaluniV1yVault = await ethers.getContractFactory('BaluniV1yVault')
  //await upgrades.forceImport('0xdE23f8ABCa49B363A86eeBa60017AaF6bB0C29a5', BaluniV1yVault)
  //await upgrades.prepareUpgrade('0xdE23f8ABCa49B363A86eeBa60017AaF6bB0C29a5', BaluniV1yVault)
  const baluniVault = await upgrades.upgradeProxy('0x196D5479088Aada724119FBaE7B04a292cF6F0d3', BaluniV1yVault, {
    kind: 'uups',
  })
  await baluniVault?.waitForDeployment()
  console.log('BaluniV1yVault upgraded to:', baluniVault.target) */

  //await upgrades.admin.changeProxyAdmin('0x18F5429a422dA0B7c340A304212a49A02009aD36', '0x84F07be28ecd5b29Df340be8b065A6113a8e893e')
  //await upgrades.admin.transferProxyAdminOwnership('0x18F5429a422dA0B7c340A304212a49A02009aD36', '0x8aA5F726d9F868a21a8bd748E2f1E43bA31eb670')

  /*  const BaluniV1DCAVault = await ethers.getContractFactory('BaluniV1DCAVault')
   //await upgrades.forceImport('0x18F5429a422dA0B7c340A304212a49A02009aD36', BaluniV1DCAVault)
   //await upgrades.prepareUpgrade('0x18F5429a422dA0B7c340A304212a49A02009aD36', BaluniV1DCAVault)
   const baluniDCAVault = await upgrades.upgradeProxy('0x18F5429a422dA0B7c340A304212a49A02009aD36', BaluniV1DCAVault, {
     kind: 'uups',
     call: {
       fn: 'reinitialize',
       args: ['Baluni DCA Vault', 'bdUSDCxWBTC', USDC, WBTC, '0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', 3600, 8],
     },
   })
   await baluniDCAVault?.waitForDeployment()
   console.log('BaluniV1DCAVault upgraded to:', baluniDCAVault.target) */

  /* const BaluniV1VaultRegistry = await ethers.getContractFactory('BaluniV1VaultRegistry')
 
  await upgrades.prepareUpgrade('0x922b999C559a76438afB79c61ad62B37e30ffc87', BaluniV1VaultRegistry)
 
  const baluniVaultRegistry = await upgrades.upgradeProxy(
    '0x922b999C559a76438afB79c61ad62B37e30ffc87',
    BaluniV1VaultRegistry,
    {
      kind: 'uups',
    }
  )
 
  await baluniVaultRegistry?.waitForDeployment()
 
  console.log('BaluniV1VaultRegistry upgraded to:', baluniVaultRegistry.target) */

  /* const BaluniV1PoolRegistry = await ethers.getContractFactory('BaluniV1PoolRegistry')
  await upgrades.prepareUpgrade('0x84436609a3a6E3023aF5691BCa9e00280a3E360b', BaluniV1PoolRegistry)
  const baluniPoolRegistry = await upgrades.upgradeProxy(
    '0x84436609a3a6E3023aF5691BCa9e00280a3E360b',
    BaluniV1PoolRegistry,
    {
      kind: 'uups',
    }
  )
  await baluniPoolRegistry?.waitForDeployment()
  console.log('BaluniV1PoolRegistry upgraded to:', baluniPoolRegistry.target) */

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
