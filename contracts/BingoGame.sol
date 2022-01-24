//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
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

    function mintCards(address owner, uint256 number, uint256 randomSeed) external {
        require(number > 0, "number of cards to mint < 1");
        require(!hasStarted(), "game has already started");

        if (owner == address(0x0)) {
            // TODO Should this be tx.origin instead in case this call is nested?
            owner = msg.sender;
        }

        if (randomSeed == 0) {
            randomSeed = random();
        }

        for (uint256 i = 0; i < number; i++) {
            mintCard(owner, randomSeed);
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

    function mintCard(address owner, uint256 randomSeed) internal {
        tokenIdCounter.increment();
        uint256 newCardId = tokenIdCounter.current();

        idToCardValues[newCardId] = generateCardValues();
        _safeMint(owner, newCardId);
    }

    function getColumnValues(uint8 columnIndex) internal view virtual returns (uint8[15] memory) {
        uint8[15][5] memory columnValues;
        columnValues[0] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
        columnValues[1] = [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30];
        columnValues[2] = [31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45];
        columnValues[3] = [46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60];
        columnValues[4] = [61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75];
        return columnValues[columnIndex];
    }

    // TODO implement
    function generateCardValues() internal view virtual returns (uint8[25] memory values) {
        return values;
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