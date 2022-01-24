//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./lib/BingoCard.sol";

contract BingoGame is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIdCounter;

    // TODO Should the card values be abi.encode/abi.encodePacked to save space?
    mapping(uint256 => uint8[25]) private idToCardValues;
    uint8[75] public calledNumbers;

    constructor() ERC721("BingoCard", "BC") {}

    function mintCards(address owner, uint8[25][] memory cards) external {
        require(cards.length > 0, "number of cards to mint < 1");
        require(!hasStarted(), "game has already started");

        if (owner == address(0x0)) {
            // TODO Should this be tx.origin instead in case this call is nested?
            owner = msg.sender;
        }

        for (uint256 i = 0; i < cards.length; i++) {
            mintCard(owner, cards[i]);
        }
    }

    function getCardValues(uint256 tokenId) external view virtual returns (uint8[25] memory) {
        return idToCardValues[tokenId];
    }

    function hasStarted() public view virtual returns (bool) {
        return calledNumbers.length > 0 && calledNumbers[0] > 0;
    }

    function runGame() external {
        // TODO Have Chainlink VRF or something similar provide randomness seed for the game.
    }

    function mintCard(address owner, uint8[25] memory card) internal {
        BingoCard.validate(card);

        tokenIdCounter.increment();
        uint256 newCardId = tokenIdCounter.current();

        idToCardValues[newCardId] = card;
        _safeMint(owner, newCardId);
    }

    // TODO This is likely a bad way to generate random numebers,
    // need something like Chainlike VRF instead.
    function random() internal view virtual returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            block.difficulty, blockhash(block.number - 1), msg.sender
        )));
    }

    function _baseURI() override internal view virtual returns (string memory) {
        return "data:application/json,";
    }
}