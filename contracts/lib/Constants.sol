//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

library Constants {
    // Width and height of the card.
    uint8 constant internal CARD_WIDTH_HEIGHT = 5;
    uint8 constant internal MAX_VALUE = 75;
    uint8 constant internal FREE_VALUE = 0;
    uint8 constant internal FREE_VALUE_INDEX = 12;

    function getAllCallableNumbers() internal pure returns (uint8[75] memory callableNumbers) {
        callableNumbers = [
            // B
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
            // I
            16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
            // N
            31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45,
            // G
            46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
            // O
            61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75
        ];
    }

    function getColumnValuesBitmask(uint8 columnIndex) internal pure returns (uint80) {
        require(columnIndex < CARD_WIDTH_HEIGHT, "column index > 4");

        uint80[5] memory columnValuesBitmask = [
            // B: 1-15
            uint80(65534),
            // I: 16-30
            uint80(2147418112),
            // N: 31-45
            uint80(70366596694016),
            // G: 46-60
            uint80(2305772640469516288),
            // O: 61-75
            uint80(75555557882905109725184)
        ];
        return columnValuesBitmask[columnIndex];
    }
}