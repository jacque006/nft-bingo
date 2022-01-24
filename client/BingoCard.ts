import { randomInt } from "crypto";
import { BigNumber } from "ethers";
import {
  CARD_WIDTH_HEIGHT,
  COLUMN_VALUES,
  FREE_VALUE_INDEX,
  FREE_VALUE,
} from "./Constants";

export default class BingoCard {
  constructor(
    public readonly tokenId: BigNumber,
    public readonly values: number[]
  ) {}

  public static async generateRandomValues(): Promise<number[]> {
    const cardValues: number[] = [];
    for (let colIdx = 0; colIdx < CARD_WIDTH_HEIGHT; colIdx++) {
      const columnValues = COLUMN_VALUES[colIdx].slice();
      for (let rowIdx = 0; rowIdx < CARD_WIDTH_HEIGHT; rowIdx++) {
        if (cardValues.length === FREE_VALUE_INDEX) {
          cardValues.push(FREE_VALUE);
          continue;
        }

        const randIdx = randomInt(0, columnValues.length);
        const [val] = columnValues.splice(randIdx, 1);
        cardValues.push(val);
      }
    }
    return cardValues;
  }
}
