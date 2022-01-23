import { expect } from "chai";
import { BigNumber, Signer } from "ethers";
import { ethers } from "hardhat";
import { BingoGame, BingoGame__factory } from "../typechain-types";

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

    const txn = await game.createCards(signerAddress, numCards);

    const txnReceipt = await txn.wait(1);
    const events = txnReceipt.events?.filter(
      (e) => e.eventSignature === "Transfer(address,address,uint256)"
    );
    expect(events).to.have.lengthOf(numCards);

    const cardIds = events?.map((e) =>
      BigNumber.from(e.args?.tokenId).toNumber()
    );
  });
});
