import { expect } from "chai";

describe("BaluniV1Pool", function () {
  // Helper functions
  function calculateFee(amount: number, swapFeeBps: number): number {
    return (amount * swapFeeBps) / 10000;
  }

  function adjustAmountAndRate(
    amount: number,
    rate: number,
    fromDecimal: number,
    toDecimal: number,
  ): { adjustedAmount: number; adjustedRate: number } {
    let adjustedAmount: number;
    let adjustedRate: number;

    if (fromDecimal > toDecimal) {
      const factor = 10 ** (fromDecimal - toDecimal);
      adjustedAmount = amount / factor; // Correct division for scaling down
      adjustedRate = rate;
    } else if (fromDecimal < toDecimal) {
      const factor = 10 ** (toDecimal - fromDecimal);
      adjustedAmount = amount;
      adjustedRate = rate * factor; // Correct multiplication for scaling up
    } else {
      adjustedAmount = amount;
      adjustedRate = rate;
    }

    return { adjustedAmount, adjustedRate };
  }

  async function simulateSwap(
    amount: number,
    rate: number,
    swapFeeBps: number,
    fromDecimal: number,
    toDecimal: number,
    contractBalance: number,
  ): Promise<number> {
    const fee = calculateFee(amount, swapFeeBps);
    const amountAfterFee = amount - fee;

    const { adjustedAmount, adjustedRate } = adjustAmountAndRate(amountAfterFee, rate, fromDecimal, toDecimal);

    const receivedAmount = (adjustedAmount * adjustedRate) / 10 ** toDecimal;

    if (contractBalance < receivedAmount) {
      throw new Error("Insufficient Liquidity");
    }

    return receivedAmount;
  }

  describe("simulate swap", function () {
    it("should simulate ETH to USDC swap correctly", async function () {
      const amountEth = 2 * 10 ** 18; // 2 ETH
      const rateEthToUsdc = 3748153863; // Rate for ETH to USDC
      const fromDecimalEth = 18; // ETH decimals
      const toDecimalUsdc = 6; // USDC decimals
      const swapFeeBps = 30; // Swap fee in basis points (0.30%)
      const contractBalanceUsdc = 200000000000000; // High contract balance for USDC to ensure no liquidity issue

      const result = await simulateSwap(
        amountEth,
        rateEthToUsdc,
        swapFeeBps,
        fromDecimalEth,
        toDecimalUsdc,
        contractBalanceUsdc,
      );

      const resultUsd = result / 10 ** 6; // Convert to readable USDC
      const expectedAmount = 7473.81880282;

      expect(resultUsd).to.be.closeTo(expectedAmount, 0.0001);
    });
  });
});
