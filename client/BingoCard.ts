import { BigNumber } from "ethers";
import {
  NUM_VALUES,
  VALID_COLUMN_VALUES,
  FREE_VALUE,
  VALUES_PER_COLUMN,
} from "./constants";

type DuplicateValue = {
  value: number;
  count: number;
};
type NumberMap = {
  [key: number]: number;
};

export default class BingoCard {
  constructor(
    public readonly tokenId: BigNumber,
    public readonly values: number[]
  ) {}

  private getDuplicateValues(): DuplicateValue[] {
    const valueCounter = this.values.reduce((prev, value) => {
      if (!prev[value]) {
        prev[value] = 1;
        return prev;
      }

      prev[value] += 1;
      return prev;
    }, {} as NumberMap);

    return Object.entries<number>(valueCounter).reduce(
      (prev, [value, count]) => {
        if (count < 2) {
          return prev;
        }

        return [...prev, { value: parseInt(value), count }];
      },
      [] as DuplicateValue[]
    );
  }

  private validateColumnValues() {
    for (let i = 0; i < this.values.length; i++) {
      const v = this.values[i];
      const columnIdx = i % VALUES_PER_COLUMN;
      const validValueSet = VALID_COLUMN_VALUES[columnIdx];

      if (!validValueSet.has(v)) {
        const validValuesStr = Array.from(validValueSet.values()).join(", ");
        throw new Error(
          `invalid column value ${v} at ${i} in column ${columnIdx}, expected one of ${validValuesStr}`
        );
      }
    }
  }

  public validate() {
    if (this.values.length !== NUM_VALUES) {
      throw new Error(
        `invalid number of card values. got ${this.values.length}, expected ${NUM_VALUES}`
      );
    }

    const middleIdx = Math.ceil(NUM_VALUES / 2);
    if (this.values[middleIdx] !== FREE_VALUE) {
      throw new Error(
        `invalid center value at ${middleIdx}. got ${this.values[middleIdx]}, expected ${FREE_VALUE}`
      );
    }

    const duplicates = this.getDuplicateValues();
    if (duplicates.length) {
      throw new Error(
        `duplicate value(s): ${duplicates
          .map((d) => `${d.count} ${d.value}'s`)
          .join(", ")}`
      );
    }

    this.validateColumnValues();
  }
}
