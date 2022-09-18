// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract PokemonNames {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }

    function firstStageNames(uint256 _index)
        external
        pure
        returns (string memory)
    {
        string[5] memory _firstStageNames = [
            "Bulbasaur",
            "Charmander",
            "Squirtle",
            "Oddish",
            "Poliwag"
        ];
        return _firstStageNames[_index];
    }

    function secondStageNames(uint256 _index)
        external
        pure
        returns (string memory)
    {
        string[5] memory _secondStageNames = [
            "Ivysaur",
            "Charmeleon",
            "Wartortle",
            "Gloom",
            "Poliwhirl"
        ];
        return _secondStageNames[_index];
    }

    function thirdStageNames(uint256 _index)
        external
        pure
        returns (string memory)
    {
        string[7] memory _thirdStageNames = [
            "Venusaur",
            "Charizard",
            "Blastoise",
            "Vileplume",
            "Poliwrath",
            "Bellossom",
            "Politoed"
        ];
        return _thirdStageNames[_index];
    }
}
