import { upgrades } from 'hardhat'

async function main() {
  await upgrades.admin.changeProxyAdmin('', '')
  console.log('Proxy admin changed successfully')
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
