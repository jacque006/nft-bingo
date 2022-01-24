//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

import "./Constants.sol";

library BingoCard {
    function validate(uint8[25] memory card) internal pure {
        uint80 duplicateValuesBitmask;

        for (uint i = 0; i < card.length; i++) {
            // Validate value in range.
            require(card[i] <= Constants.MAX_VALUE, "value > 75");

            uint80 valueBitmask = uint80(1 << card[i]);

            // Validate value not duplicated.
            require(duplicateValuesBitmask & valueBitmask != valueBitmask, "duplicate value detected");
            duplicateValuesBitmask |= valueBitmask;

            // Validate middle of card is free.
            if (i == Constants.FREE_VALUE_INDEX) {
                require(
                    card[i] == Constants.FREE_VALUE,
                    "card center value not 0 (free)"
                );
                continue;
            }

            // Validate value within range of column.
            uint80 columnValuesBitmask = Constants.getColumnValuesBitmask(uint8(i / Constants.CARD_WIDTH_HEIGHT));
            require(columnValuesBitmask & valueBitmask == valueBitmask, "column value not valid");
        }
    }

    function getWinningLines(uint8[25] memory card, uint80 calledNumbersBitmask) internal pure returns (uint8[5][] memory) {
        uint80[12] memory lineBitmasks = getLineBitmasks(card);
    }

    function getLineBitmasks(uint8[25] memory card) private pure returns (uint80[12] memory) {

    }
}