import { expect } from "chai";
import { BigNumber, Signer } from "ethers";
import { ethers } from "hardhat";
import { BingoGame, BingoGame__factory } from "../typechain-types";
import { BingoCard, NUM_VALUES } from "../client";

describe("integration", () => {
  let signer: Signer;
  let game: BingoGame;

  before(async function () {
    const [_signer] = await ethers.getSigners();
    signer = _signer;
    game = await new BingoGame__factory(signer).deploy();
  });

  it("runs a bingo game successfully", async function () {
    const numCards = 10;
    const rawCards: number[][] = new Array<number[]>(numCards).fill(
      new Array<number>(NUM_VALUES).fill(0)
    );
    const signerAddress = await signer.getAddress();

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
    for (let i = 0; i < cards.length; i++) {
      const c = cards[i];
      expect(c.values).to.equal(rawCards[i]);
      expect(c.tokenId).to.equal(i + 1);
    }
  });
});
