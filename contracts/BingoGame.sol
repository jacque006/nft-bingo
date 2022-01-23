//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// TODO debug, remove
import "hardhat/console.sol";

contract BingoGame is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIdCounter;

    // TODO Should the card values be abi.encode/abi.encodePacked to save space?
    mapping(uint256 => uint8[25]) private idToCardValues;
    uint8[74] public calledNumbers;

    constructor() ERC721("BingoCard", "BC") {}

    function createCard(address owner) public {
        require(!hasStarted(), "game has already started");

        tokenIdCounter.increment();
        uint256 newCardId = tokenIdCounter.current();

        idToCardValues[newCardId] = generateCardValues();
        _safeMint(owner, newCardId);
    }

    function createCards(address owner, uint256 number) external {
        for (uint256 i = 0; i < number; i++) {
            createCard(owner);
        }
    }

    function getCardValues(uint256 tokenId) external view virtual returns (uint8[25] memory) {
        return idToCardValues[tokenId];
    }

    function hasStarted() public view virtual returns (bool) {
        return calledNumbers.length > 0;
    }

    function runGame(uint8[74] memory _calledNumbers) external {
        calledNumbers = _calledNumbers;
    }

    // TODO implement
    function generateCardValues() internal view virtual returns (uint8[25] memory values) {
        return values;
    }

    function _baseURI() override internal view virtual returns (string memory) {
        return "data:application/json,";
    }
}