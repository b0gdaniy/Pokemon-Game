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

    uint256 internal currentId;
    mapping(address => mapping(uint256 => Pokemon)) internal pokemonOf;

    modifier lvlUpdate(uint256 _tokenId) {
        uint256 pokemonLvl = lvlToken.balanceOf(msg.sender);
        pokemonOf[msg.sender][_tokenId].level = pokemonLvl;

        _;
    }

    constructor(PokemonLevelToken _lvlToken, StoneToken _stoneToken)
        NFTTemplate("Pokemon", "PKMN")
    {
        lvlToken = _lvlToken;
        stoneToken = _stoneToken;
    }

    receive() external payable {
        require(
            msg.value > 0.01 ether,
            "The amount sent must be greater than 0.01 ETH"
        );

        safeMint(msg.sender, currentId);
        pokemonOf[msg.sender][currentId].tokenId = currentId;
        currentId++;
    }

    function createPokemon(string memory _name, uint256 _tokenId) external {
        uint256 pokemonLvl = lvlToken.balanceOf(msg.sender);
        require(pokemonLvl > 0, "You don't have PLVL tokens");

        Pokemon memory pokemon = Pokemon(_tokenId, _name, pokemonLvl, 1);

        pokemonOf[msg.sender][_tokenId] = pokemon;
    }

    function _deletePokemon(uint256 _tokenId) internal {
        require(
            _isApprovedOrOwner(msg.sender, _tokenId),
            "Not an owner of token or approved for it"
        );
        _burn(_tokenId);

        delete pokemonOf[msg.sender][_tokenId];
    }

    // function evolution(uint256 _tokenId) external lvlUpdate(_tokenId) {
    // 	require()
    // }
}
