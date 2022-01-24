//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

import "./Constants.sol";

// TODO remove
import "hardhat/console.sol";

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

    // TODO Remove
    function logLine(uint8[5] memory line) private view {
        string memory s = string(abi.encodePacked(line[0], line[1], line[2], line[3], line[4]));
        console.log("line", s);
    }

    // TODO view -> pure
    function getWinningLines(uint8[25] memory card, uint80 calledNumbersBitmask) internal view returns (uint8[5][] memory) {
        uint8[5][12] memory lines;
        uint80[12] memory lineBitmasks;
        uint8 winningLinesCount = 0;
        uint8[5][12] memory maxWinningLines;

        (lines, lineBitmasks) = getLinesAndBitmasks(card);

        uint8 i;
        for (i = 0; i < lines.length; i++) {
            logLine(lines[i]);
            console.log("bitmask", lineBitmasks[i]);
            if (calledNumbersBitmask & lineBitmasks[i] == lineBitmasks[i]) {
                maxWinningLines[winningLinesCount] = lines[i];
                winningLinesCount++;
            }
        }

        if (winningLinesCount > 0) {
            uint8[5][] memory winningLines = new uint8[5][](winningLinesCount);
            for (i = 0; i < winningLinesCount; i++) {
                winningLines[i] = maxWinningLines[i];
            }
            return winningLines;
        }
    }

    function getLinesAndBitmasks(uint8[25] memory card) private pure returns (uint8[5][12] memory lines, uint80[12] memory lineBitmasks) {
        /**
         * Cell to card index:
         *
         * --------------------------
         * |  0 |  1 |  2 |  3 |  4 |
         * --------------------------
         * |  5 |  6 |  7 |  8 |  9 |
         * --------------------------
         * | 10 | 11 | 12 | 13 | 14 |
         * --------------------------
         * | 15 | 16 | 17 | 18 | 19 |
         * --------------------------
         * | 20 | 21 | 22 | 23 | 24 |
         * --------------------------
         */
        // top left -> bottom right
        lines[0] = [
            card[0],
            card[6],
            card[12],
            card[18],
            card[24]
        ];
        lineBitmasks[0] = getLineBitmask(lines[0]);
        // top right -> bottom left
        lines[1] = [
            card[4],
            card[9],
            card[12],
            card[16],
            card[20]
        ];
        lineBitmasks[1] = getLineBitmask(lines[1]);
        // row 0
        lines[2] = [
            card[0],
            card[1],
            card[2],
            card[3],
            card[4]
        ];
        lineBitmasks[2] = getLineBitmask(lines[2]);
        // row 1
        lines[3] = [
            card[5],
            card[6],
            card[7],
            card[8],
            card[9]
        ];
        lineBitmasks[3] = getLineBitmask(lines[3]);
        // row 2
        lines[4] = [
            card[10],
            card[11],
            card[12],
            card[13],
            card[14]
        ];
        lineBitmasks[4] = getLineBitmask(lines[4]);
        // row 3
        lines[5] = [
            card[15],
            card[16],
            card[17],
            card[18],
            card[19]
        ];
        lineBitmasks[5] = getLineBitmask(lines[5]);
        // row 4
        lines[6] = [
            card[20],
            card[21],
            card[22],
            card[23],
            card[24]
        ];
        lineBitmasks[6] = getLineBitmask(lines[6]);
        // column 0
        lines[7] = [
            card[0],
            card[5],
            card[10],
            card[15],
            card[20]
        ];
        lineBitmasks[7] = getLineBitmask(lines[7]);
        // column 1
        lines[8] = [
            card[1],
            card[6],
            card[11],
            card[16],
            card[21]
        ];
        lineBitmasks[8] = getLineBitmask(lines[8]);
        // column 2
        lines[9] = [
            card[2],
            card[7],
            card[12],
            card[17],
            card[22]
        ];
        lineBitmasks[9] = getLineBitmask(lines[9]);
        // column 3
        lines[10] = [
            card[3],
            card[8],
            card[13],
            card[18],
            card[23]
        ];
        lineBitmasks[10] = getLineBitmask(lines[10]);
        // column 4
        lines[11] = [
            card[4],
            card[9],
            card[14],
            card[19],
            card[24]
        ];
        lineBitmasks[11] = getLineBitmask(lines[11]);
    }

    function getLineBitmask(uint8[5] memory line) private pure returns (uint80 bitmask) {
        bitmask |= uint80(1 << line[0]);
        bitmask |= uint80(1 << line[1]);
        bitmask |= uint80(1 << line[2]);
        bitmask |= uint80(1 << line[3]);
        bitmask |= uint80(1 << line[4]);
    }
}