// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";

contract PokemonToken is NFTTemplate {
    constructor() NFTTemplate("Pokemon", "PKMN") {}
}
