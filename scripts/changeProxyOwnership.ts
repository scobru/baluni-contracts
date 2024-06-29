import { ethers, upgrades } from 'hardhat'

async function main() {
  await upgrades.admin.transferProxyAdminOwnership('', '')
  console.log('Proxy admin ownership transferred successfully')
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
