import { expect } from "chai";
import { BigNumber, Signer } from "ethers";
import { ethers } from "hardhat";
import { BingoGame, BingoGame__factory } from "../typechain-types";
import { BingoCard } from "../client";

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
    const signerAddress = await signer.getAddress();

    // TODO Consider passing a determinisitc seed here so game is always the same
    // Maybe have test suite generate it so results can be reproduced.
    const txn = await game.mintCards(signerAddress, numCards, 0);

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
    for (const c of cards) {
      c.validate();
    }
  });
});
