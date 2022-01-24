//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

library Constants {
    // Width and height of the card.
    uint8 constant internal CARD_WIDTH_HEIGHT = 5;
    uint8 constant internal VALUES_PER_COLUMN = 15;
    uint8 constant internal MAX_VALUE = 75;
    uint8 constant internal FREE_VALUE = 0;
    // Free value's x/y coordinates in 2D representation of card.
    uint8 constant internal FREE_VALUE_XY = 2;

    function getAllValues() internal pure returns (uint8[75] memory allValues) {
        allValues = [
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

    function getColumnValues(uint8 columnIndex) internal pure returns (uint8[15] memory columnValues) {
        require(columnIndex < CARD_WIDTH_HEIGHT, "column index > 4");

        uint8[75] memory allValues = getAllValues();
        uint8 startIdx = columnIndex * VALUES_PER_COLUMN;
        columnValues = [
            allValues[startIdx],
            allValues[startIdx + 1],
            allValues[startIdx + 2],
            allValues[startIdx + 3],
            allValues[startIdx + 4],
            allValues[startIdx + 5],
            allValues[startIdx + 6],
            allValues[startIdx + 7],
            allValues[startIdx + 8],
            allValues[startIdx + 9],
            allValues[startIdx + 10],
            allValues[startIdx + 11],
            allValues[startIdx + 12],
            allValues[startIdx + 13],
            allValues[startIdx + 14]
        ];
    }
}