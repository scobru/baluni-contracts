import { ethers } from "hardhat";
import * as dotenv from "dotenv";
import { Contract } from "ethers";
import erc20Abi from "../abis/common/ERC20.json";
dotenv.config();

const routerAddress = "0x19f330eba98ffd47a01f8f2afb0b9863a24497dd"; // Polygon

async function main() {
  const signers = await ethers.getSigners();
  const routerCtx = await ethers.getContractAt("Router", routerAddress, signers[0]);
  const agentAddress = await routerCtx?.getAgentAddress(signers[0].address);

  const tokenAddress = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";

  const tokenContract = new Contract(tokenAddress, erc20Abi, signers[0]);
  const tokenBalance = await tokenContract.balanceOf(agentAddress);

  const dataTransferFromSenderToAgent = tokenContract.interface.encodeFunctionData("transfer", [
    signers[0].address,
    tokenBalance,
  ]);

  console.log("Signer:", signers[0].address);
  console.log("Agent Address:", agentAddress);

  const tx = {
    to: tokenAddress,
    data: dataTransferFromSenderToAgent,
    value: 0,
  };

  // Perform the execute call
  const executeTx = await routerCtx.execute([tx], [tokenAddress]); // Adjust the gas limit as necessary
  await executeTx.wait();

  console.log(`Executed transferFrom via router at transaction: ${executeTx.hash}`);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
