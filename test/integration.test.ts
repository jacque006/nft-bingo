import { expect } from "chai";
import { utils } from "ethers";
import { ethers } from "hardhat";
import {

} from "../typechain-types";

describe("integration", () => {
  before(async function () {
    const [signer] = await ethers.getSigners();
  });

  it("runs a bingo game successfully", async function () {
    
  });
});
