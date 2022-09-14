// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";

contract StoneToken is NFTTemplate {
    constructor() NFTTemplate("Stone", "STON") {}
}
