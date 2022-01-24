//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

import "./Constants.sol";

library BingoCard {
    // TODO implement
    function hasDuplicateValues(uint8[25] memory card) internal pure returns (bool) {
        // validColumnValuesBitmask |= uint80(1 << columnValues[i]);
        return false;
    }

    function validateColumnValues(uint8 columnIndex, uint8[5] memory column) internal pure {
        uint80 columnValuesBitmask = Constants.getColumnValuesBitmask(columnIndex);

        for (uint8 i = 0; i < column.length; i++) {
            if (columnIndex == Constants.FREE_VALUE_XY &&
                i == Constants.FREE_VALUE_XY
            ) {
                require(
                    column[Constants.FREE_VALUE_XY] == Constants.FREE_VALUE,
                    "card center value not 0 (free)"
                );
                continue;
            }
            require(column[i] <= Constants.MAX_VALUE, "value > 75");
            uint80 valueBitmask = uint80(1 << column[i]);
            require(columnValuesBitmask & valueBitmask == valueBitmask, "column value not valid");
        }
    }

    function validate(uint8[25] memory card) internal pure {
        require(!hasDuplicateValues(card), "card has duplicate values");

        for (uint8 colIdx = 0; colIdx < Constants.CARD_WIDTH_HEIGHT; colIdx++) {
            uint8 startIdx = colIdx * Constants.CARD_WIDTH_HEIGHT;
            uint8[5] memory col = [
                card[startIdx],
                card[startIdx + 1],
                card[startIdx + 2],
                card[startIdx + 3],
                card[startIdx + 4]
            ];
            validateColumnValues(colIdx, col);
        }
    }
}