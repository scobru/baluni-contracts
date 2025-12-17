import { ethers, upgrades } from 'hardhat'

async function main() {
    const BaluniV1IndexRegistry = await ethers.getContractFactory('BaluniV1IndexRegistry')
    await upgrades.prepareUpgrade('', BaluniV1IndexRegistry)
    const baluniIndexRegistry = await upgrades.upgradeProxy('', BaluniV1IndexRegistry, {
        kind: 'uups',
    })
    await baluniIndexRegistry?.waitForDeployment()
    console.log('BaluniV1IndexRegistry upgraded to:', baluniIndexRegistry.target)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
