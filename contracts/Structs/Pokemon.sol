// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../Enums/PokemonsNum.sol";

struct Pokemon {
    string name;
    uint256 stage;
    PokemonsNum index;
}
