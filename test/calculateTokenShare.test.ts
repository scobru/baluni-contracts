// Importa il contratto che vuoi testare
import { TestBaluniRouter } from "../contracts/TestBaluniRouter.sol";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("TestBaluniRouter", function () {
  it("Should calculate token share correctly", async function () {
    // Deploya il contratto
    const TestBaluniRouter = await ethers.getContractFactory("TestBaluniRouter");
    const testBaluniRouter = await TestBaluniRouter.deploy();

    // Calcola la quota di token attesa
    const expectedShare = 0.00001 * 0.001 * 1e6; // La quota attesa è di 0.02 * 0.001 * 1e6 token
    const totalBaluni = 1 * 1e18;
    const totalTokenValueUSD = 0.0001 * 1e6;
    const amountBaluni = 0.001 * 1e18;
    const decimal = 6;
    // Calcola la quota di token
    const result = await testBaluniRouter.calculateTokenShare(totalBaluni, totalTokenValueUSD, amountBaluni, decimal);

    // Verifica che il risultato sia corretto
    expect(result).to.equal(expectedShare);
  });
});
