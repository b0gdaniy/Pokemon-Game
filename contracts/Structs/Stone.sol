// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../Enums/StoneType.sol";

struct Stone {
    uint256 tokenId;
    string name;
    StoneType stoneType;
}
