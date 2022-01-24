import { expect } from "chai";
import { BigNumber, Signer } from "ethers";
import { ethers } from "hardhat";
import { BingoGame, BingoGame__factory } from "../typechain-types";
import { BingoCard, ALL_VALUES } from "../client";

describe("integration", () => {
  let signer: Signer;
  let game: BingoGame;

  before(async function () {
    const [_signer] = await ethers.getSigners();
    signer = _signer;
    game = await new BingoGame__factory(signer).deploy();
  });

  it("runs a bingo game successfully", async function () {
    const numCards = 1;
    const rawCards: number[][] = await Promise.all(
      new Array<number[]>(numCards)
        .fill([])
        .map(async () => BingoCard.generateRandomValues())
    );

    const signerAddress = await signer.getAddress();

    // Mint bingo cards.
    const txn = await game.mintCards(signerAddress, rawCards);

    const txnReceipt = await txn.wait(1);
    const events = txnReceipt.events?.filter(
      (e) => e.eventSignature === "Transfer(address,address,uint256)"
    );
    expect(events).to.have.lengthOf(numCards);

    const cardIds = events?.map((e) => BigNumber.from(e.args?.tokenId));
    if (!cardIds || !cardIds.length) {
      throw new Error("cardIds invalid");
    }
    const cards = await Promise.all(
      cardIds.map(async (id) => {
        const values = await game.getCardValues(id);
        return new BingoCard(id, values);
      })
    );
    // Make sure cards match what we passed in.
    for (let i = 0; i < cards.length; i++) {
      const c = cards[i];
      expect(c.values).to.deep.equal(rawCards[i]);
      expect(c.tokenId).to.equal(i);
    }

    await game.runGame();

    // Verify called numbers match every callable value.
    const calledNumbers = await game.getCalledNumbers();
    expect(calledNumbers).to.have.lengthOf(ALL_VALUES.length);
    const allValuesMap = ALL_VALUES.slice().reduce<Record<number, boolean>>(
      (prev, n) => ({
        ...prev,
        [n]: true,
      }),
      {}
    );
    for (const n of calledNumbers) {
      delete allValuesMap[n];
    }
    expect(Object.keys(allValuesMap).length).to.equal(0);

    await game.determineWinners();

    // Verify at least one winner with valid line(s).
    const winningIds = await game.getWinningTokenIds();
    expect(winningIds.length).to.be.greaterThan(0);
    for (const id of winningIds) {
      const winningLines = await game.getWinningLines(id);
      expect(winningLines.length).to.equal(5);

      // TODO Debug, remove
      console.warn("#".repeat(10));
      const cardValues = await game.getCardValues(id);
      console.warn(id, cardValues);
      console.warn(winningLines);
    }
  });
});
