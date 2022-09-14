// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";
import "./PokemonLevelToken.sol";
import "./StoneToken.sol";

contract PokemonToken is NFTTemplate {
    PokemonLevelToken public lvlToken;
    StoneToken public stoneToken;

    struct Pokemon {
        uint256 tokenId;
        string name;
        uint256 level;
        uint256 stage;
    }

    mapping(address => mapping(uint256 => Pokemon)) internal pokemons;

    modifier lvlUpdate(uint256 _tokenId) {
        uint256 pokemonLvl = lvlToken.balanceOf(msg.sender);
        pokemons[msg.sender][_tokenId].level = pokemonLvl;

        _;
    }

    constructor(PokemonLevelToken _lvlToken, StoneToken _stoneToken)
        NFTTemplate("Pokemon", "PKMN")
    {
        lvlToken = _lvlToken;
        stoneToken = _stoneToken;
    }

    function createPokemon(
        string memory _name,
        uint256 _tokenId,
        string memory _tokenUri
    ) external {
        uint256 pokemonLvl = lvlToken.balanceOf(msg.sender);
        require(pokemonLvl > 0, "You don't have PLVL tokens");

        safeMint(msg.sender, _tokenId, _tokenUri);

        Pokemon memory pokemon = Pokemon(_tokenId, _name, pokemonLvl, 1);

        pokemons[msg.sender][_tokenId] = pokemon;
    }

    //function lvlUpdate()

    //function evolution() external {}
}
