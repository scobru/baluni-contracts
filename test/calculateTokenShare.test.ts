// Importa il contratto che vuoi testare
import { TestBaluniRouter } from "../contracts/TestBaluniRouter.sol";
import { expect } from "chai";
import { parseEther } from "ethers";
import { ethers } from "hardhat";

describe("TestBaluniRouter", function () {
  const totalBaluni = parseEther("1");
  const amountBaluni = parseEther("0.01");
  const decimal = 6;
  const totalTokenValueUSD = Number(0.001 * 10 ** decimal);
  const factor = 10 ** 18 - decimal;

  it("Should calculate token share correctly", async function () {
    const TestBaluniRouter = await ethers.getContractFactory("TestBaluniRouter");
    const testBaluniRouter = await TestBaluniRouter.deploy();
    const expectedShare = ((Number(amountBaluni) / factor) * totalTokenValueUSD) / (Number(totalBaluni) / factor);
    const result = await testBaluniRouter.calculateTokenShare(totalBaluni, totalTokenValueUSD, amountBaluni, decimal);
    console.log("Expected share: ", expectedShare.toString());
    console.log("Result: ", result.toString());
    expect(result).to.equal(expectedShare);
  });

  it("Should calculate token share correctly", async function () {
    const TestBaluniRouter = await ethers.getContractFactory("TestBaluniRouter");
    const testBaluniRouter = await TestBaluniRouter.deploy();
    const expectedShare2 = (Number(amountBaluni) * totalTokenValueUSD * 1e12) / Number(totalBaluni);
    const result2 = await testBaluniRouter.calculateTokenShare2(totalBaluni, totalTokenValueUSD, amountBaluni, decimal);
    console.log("Expected share: ", (expectedShare2 / 1e12).toString());
    console.log("Result: ", result2.toString());
    expect(result2).to.equal(expectedShare2 / 1e12);
  });
});
