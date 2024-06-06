"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const hardhat_1 = require("hardhat");
const dotenv = __importStar(require("dotenv"));
const ethers_1 = require("ethers");
const ERC20_json_1 = __importDefault(require("../abis/common/ERC20.json"));
dotenv.config();
const routerAddress = "0x19f330eba98ffd47a01f8f2afb0b9863a24497dd"; // Polygon
async function main() {
    const signers = await hardhat_1.ethers.getSigners();
    const routerCtx = await hardhat_1.ethers.getContractAt("Router", routerAddress, signers[0]);
    const agentAddress = await routerCtx?.getAgentAddress(signers[0].address);
    const tokenAddress = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
    const tokenContract = new ethers_1.Contract(tokenAddress, ERC20_json_1.default, signers[0]);
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
