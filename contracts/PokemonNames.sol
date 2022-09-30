// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "./IPokemonNames.sol";

/**
 * @title PokemonNames
 * @author Bohdan Pukhno
 * @dev Pokemon Names contract that returns names of Pokemons on 3 stages.
 */
contract PokemonNames is IPokemonNames {
    string public name;

    /**
     * @dev Initializes the contract. Setting the `name` of contract by the `_name` parameter passed to it.
     */
    constructor(string memory _name) {
        name = _name;
    }

    /**
     * @dev See {IPokemonNames-firstStageNames}.
     */
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

    /**
     * @dev See {IPokemonNames-secondStageNames}.
     */
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

    /**
     * @dev See {IPokemonNames-thirdStageNames}.
     */
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
