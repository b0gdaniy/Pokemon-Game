// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTTemplate is ERC721, Ownable {
    uint256 private nonce;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://...";
    }

    function random() internal returns (uint256) {
        nonce++;
        return
            uint256(
                keccak256(abi.encode(block.timestamp, msg.sender, nonce++))
            ) % 100;
    }
}
