import { ethers, upgrades } from 'hardhat'

async function main() {
  const BaluniV1AgentFactory = await ethers.getContractFactory('BaluniV1AgentFactory')
  const agentFactory = await upgrades.upgradeProxy('', BaluniV1AgentFactory)
  const instanceAgentFactory = await agentFactory?.waitForDeployment()
  console.log('BaluniV1AgentFactory upgraded to:', instanceAgentFactory.target)
  await instanceAgentFactory.changeImplementation()
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
