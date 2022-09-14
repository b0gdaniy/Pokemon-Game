// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";

contract StoneToken is NFTTemplate {
    struct Stone {
        uint256 tokenId;
        string stoneType;
    }

    string[] public stoneTypes;

    uint256 private currentId;

    mapping(address => mapping(uint256 => Stone)) private stoneOf;

    constructor(string[] memory _stoneTypes) NFTTemplate("Stone", "STN") {
        for (uint256 i = 0; i < _stoneTypes.length; ++i) {
            stoneTypes.push(_stoneTypes[i]);
        }
    }

    receive() external payable {
        require(
            msg.value > 0.01 ether,
            "The amount sent must be greater than 0.01 ETH"
        );

        safeMint(msg.sender, currentId);
        stoneOf[msg.sender][currentId].tokenId = currentId;
        currentId++;

        giveStoneTo();
    }

    function giveStoneTo() internal {
        if (random() > 50) {
            stoneOf[msg.sender][currentId - 1].stoneType = stoneTypes[0];
        } else {
            stoneOf[msg.sender][currentId - 1].stoneType = stoneTypes[1];
        }
    }

    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * REQUIREMENTS:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) internal {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );
        _burn(tokenId);
    }
}
