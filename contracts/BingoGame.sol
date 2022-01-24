//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./lib/BingoCard.sol";
// TODO remove
import "hardhat/console.sol";

contract BingoGame is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIdCounter;

    // TODO Should the card values be abi.encode/abi.encodePacked to save space?
    mapping(uint256 => uint8[25]) private idToCardValues;

    uint8[75] private calledNumbers;
    uint256[] private winningIds;
    mapping(uint256 => uint8[5][]) private idToWinningLines;

    constructor() ERC721("BingoCard", "BC") {}

    modifier gameHasStarted() {
        require(hasStarted(), "game not started");
        _;
    }

    modifier gameHasNotStarted {
        require(!hasStarted(), "game has already started");
        _;
    }

    function getCardValues(uint256 tokenId) external view virtual returns (uint8[25] memory) {
        return idToCardValues[tokenId];
    }

    function getCalledNumbers() external view virtual returns (uint8[75] memory) {
        return calledNumbers;
    }

    function getWinningTokenIds() external view virtual returns (uint256[] memory) {
        return winningIds;
    }

    function getWinningLines(uint256 tokenId) external view virtual returns (uint8[5][] memory) {
        return idToWinningLines[tokenId];
    }

    function hasStarted() public view virtual returns (bool) {
        return calledNumbers[0] > 0;
    }

    function mintCards(address owner, uint8[25][] memory cards) external gameHasNotStarted {
        require(cards.length > 0, "number of cards to mint < 1");

        if (owner == address(0x0)) {
            // TODO Should this be tx.origin instead in case this call is nested?
            owner = msg.sender;
        }

        for (uint256 i = 0; i < cards.length; i++) {
            mintCard(owner, cards[i]);
        }
    }

    function runGame() external gameHasNotStarted {
        // TODO Have Chainlink VRF or something similar provide randomness seed for the game.

        uint8[75] memory callableNumbers = Constants.getAllCallableNumbers();
        uint8[75] memory currentCalledNumbers;
        for (uint8 i = 0; i < calledNumbers.length; i++) {
            uint8 randIdx = uint8(random() % (callableNumbers.length - i));
            currentCalledNumbers[i] = callableNumbers[randIdx];

            for (uint8 spliceIdx = randIdx; spliceIdx < callableNumbers.length - 1; spliceIdx++) {
               callableNumbers[spliceIdx] = callableNumbers[spliceIdx + 1];
            }
        }
        calledNumbers = currentCalledNumbers;
    }

    function determineWinners() external gameHasStarted {
        uint256 numCards = tokenIdCounter.current();

        // Can skip checking first 3 numbers
        for (uint8 count = Constants.CARD_WIDTH_HEIGHT - uint8(2); count < calledNumbers.length; count++) {
            console.log("count", count);
            uint80 calledNumbersBitmask = getCalledNumbersBitmask(count);

            for (uint256 id = 0; id < numCards; id++) {
                console.log("id", count);
                uint8[5][] memory winningLines = BingoCard.getWinningLines(idToCardValues[id], calledNumbersBitmask);
                if (winningLines.length < 1) {
                    continue;
                }

                console.log("winner", id);
                winningIds.push(id);
                idToWinningLines[id] = winningLines;
            }

            if (winningIds.length > 0) {
                break;
            }
        }

        require(winningIds.length > 0, "no winners determined");

        // TODO Emit winners in events
    }

    function mintCard(address owner, uint8[25] memory card) private {
        BingoCard.validate(card);

        uint256 newCardId = tokenIdCounter.current();
        tokenIdCounter.increment();

        idToCardValues[newCardId] = card;
        _safeMint(owner, newCardId);
    }

    // TODO This is likely a bad way to generate random numebers,
    // need something like Chainlike VRF instead.
    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            block.difficulty, blockhash(block.number - 1), msg.sender
        )));
    }

    function getCalledNumbersBitmask(uint8 count) private view returns (uint80 calledNumbersBitmask) {
        for (uint8 i = 0; i < count; i++) {
            calledNumbersBitmask |= uint80(1 << calledNumbers[i]);
        }
    }

    function _baseURI() override internal view virtual returns (string memory) {
        return "data:application/json,";
    }
}