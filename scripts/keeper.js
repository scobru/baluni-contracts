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
Object.defineProperty(exports, "__esModule", { value: true });
const hardhat_1 = require("hardhat");
const dotenv = __importStar(require("dotenv"));
dotenv.config();
const tournamentAddress = "0xf823c515eAdC0C8fC2699f88F3e87389e97953b0"; // Polygon
const poolAddress = "0x26EcB9aCa9d7d44EAbbE3f4f6905DEbb115843Dc"; // Aggiungi l'indirizzo della pool al tuo file .env
async function main() {
    const signers = await hardhat_1.ethers.getSigners();
    const tournament = await hardhat_1.ethers.getContractAt("BaluniTournamentV1", tournamentAddress, signers[0]);
    const pool = await hardhat_1.ethers.getContractAt("BaluniPoolV1", poolAddress, signers[0]);
    const currentTime = Math.floor(Date.now() / 1000);
    const verificationTime = await tournament.verificationTime();
    if (currentTime >= verificationTime) {
        try {
            console.log("Tentativo di risolvere il torneo...");
            const tx = await tournament.resolveTournament();
            await tx.wait();
            console.log("Torneo risolto con successo.");
        }
        catch (error) {
            console.error("Errore nella risoluzione del torneo:", error);
        }
    }
    else {
        console.log("Non è ancora il momento di risolvere il torneo.");
    }
    try {
        const hasUnresolvedPredictions = await pool.hasAnyUnresolvedPastEndTime();
        if (hasUnresolvedPredictions) {
            console.log("Tentativo di risolvere la pool...");
            const txPool = await pool.resolve();
            await txPool.wait();
            console.log("Pool risolta con successo.");
        }
        else {
            console.log("Nessuna previsione da risolvere nella pool al momento.");
        }
    }
    catch (error) {
        console.error("Errore nella risoluzione della pool:", error);
    }
}
let counter = 0;
async function runEveryMinute() {
    try {
        await main();
        counter++;
        console.log("Counter: ", counter);
    }
    catch (error) {
        console.error(error);
    }
    setTimeout(runEveryMinute, 1 * 1 * 60 * 1000);
}
runEveryMinute();
