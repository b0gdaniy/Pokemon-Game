// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NFTTemplate
 * @author Bohdan Pukhno
 * @dev Imlementation of ERC721 token contract.
 * @notice Needs for create Pokemon Token and Stone Token.
 */
contract NFTTemplate is ERC721, Ownable {
    uint256 private nonce;

    /**
     * @dev Initializes the contract, setting the deployer as the initial owner.
     * Setting the token contracts addresses by the parameters passed to it.
     */
    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
        Ownable()
    {}

    /**
     * @dev Mins tokens to `to` with token id `tokenId`.
     *
     * REQUIREMENTS:
     * - `msg.sender` must be an owner of this contract,
     * - `tokenId` must not exist,
     * - if `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer.
     */
    function safeMint(address to, uint256 tokenId) public virtual onlyOwner {
        _safeMint(to, tokenId);
    }

    /**
     * @dev Withdraws all funds in contract.
     *
     * REQUIREMENTS:
     * - `msg.sender` must be the owner of this contract
     */
    function withdrawAll() external onlyOwner {
        _withdraw(address(this).balance);
    }

    /**
     * @dev Withdraws `_amount` funds in contract.
     *
     * REQUIREMENTS:
     * - `msg.sender` must be the owner of this contract
     */
    function withdraw(uint256 _amount) external onlyOwner {
        _withdraw(_amount);
    }

    function random(uint256 _modulus) internal returns (uint256) {
        nonce++;
        return
            uint256(
                keccak256(abi.encode(block.timestamp, msg.sender, nonce++))
            ) % _modulus;
    }

    function _withdraw(uint256 _amount) internal {
        require(address(this).balance > 0, "Not enough funds");
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Withdraw failed");
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
