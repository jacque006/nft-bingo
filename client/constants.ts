const fillArray = (start: number, count: number): number[] => {
  return new Array(count).fill(0).map((_, i) => i + start);
};

export const CARD_WIDTH = 5;
export const CARD_HEIGHT = 5;
export const FREE_VALUE = 0;
export const NUM_VALUES = CARD_WIDTH * CARD_HEIGHT;
export const VALUES_PER_COLUMN = 15;
export const VALID_COLUMN_VALUES = new Array(CARD_WIDTH)
  .fill([])
  .map((_, i) => fillArray(i * VALUES_PER_COLUMN + 1, VALUES_PER_COLUMN));
