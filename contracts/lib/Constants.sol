//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

library Constants {
    // Width and height of the card.
    uint8 constant internal CARD_WIDTH_HEIGHT = 5;
    uint8 constant internal MAX_VALUE = 75;
    uint8 constant internal FREE_VALUE = 0;
    // Free value's x/y coordinates in 2D representation of card.
    uint8 constant internal FREE_VALUE_XY = 2;

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