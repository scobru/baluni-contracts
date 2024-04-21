import { ethers } from "hardhat";
import * as dotenv from "dotenv";
import { Contract } from "ethers";
dotenv.config();

const routerAddress = "0x19f330eba98ffd47a01f8f2afb0b9863a24497dd"; // Polygon

async function main() {
  const signers = await ethers.getSigners();
  const routerCtx = await ethers.getContractAt("Router", routerAddress, signers[0]);
  const agentAddress = await routerCtx?.getAgentAddress(signers[0].address);

  const tokenAddress = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
  const transferFromAbi = ["function transfer(address recipient, uint256 amount) returns (bool)"];

  const amount = ethers.parseUnits("0.002903393552856183", 18); // Adjust the token amount and decimals as needed
  const tokenContract = new Contract(tokenAddress, transferFromAbi, signers[0]);

  const dataTransferFromSenderToAgent = tokenContract.interface.encodeFunctionData("transfer", [
    signers[0].address,
    amount,
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
