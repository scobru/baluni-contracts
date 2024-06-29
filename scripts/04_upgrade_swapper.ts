import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1Swapper = await ethers.getContractFactory('BaluniV1Swapper')
  await upgrades.prepareUpgrade('0x1d70473cF880341198C1909E236d29Afe2F220f8', BaluniV1Swapper)
  const swapper = await upgrades.upgradeProxy('0x1d70473cF880341198C1909E236d29Afe2F220f8', BaluniV1Swapper, {
    kind: 'uups',
    call: {
      fn: 'reinitialize',
      args: ['0xe81562a7e2af6F147Ff05EAbAb9B36e88830b655', 2],
    },
  })
  await swapper?.waitForDeployment()
  console.log('BaluniV1Swapper upgraded to:', swapper.target)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
