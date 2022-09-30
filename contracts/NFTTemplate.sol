// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTTemplate is ERC721, Ownable {
    uint256 private nonce;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
        Ownable()
    {}

    function safeMint(address to, uint256 tokenId) public virtual onlyOwner {
        _safeMint(to, tokenId);
    }

    function random(uint256 _modulus) internal returns (uint256) {
        nonce++;
        return
            uint256(
                keccak256(abi.encode(block.timestamp, msg.sender, nonce++))
            ) % _modulus;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://...";
    }

    function _compareStrings(string memory x, string memory y)
        internal
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(x)) == keccak256(abi.encodePacked(y));
    }
}
