// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";
import "./PokemonLevelToken.sol";
import "./StoneToken.sol";

contract PokemonToken is NFTTemplate {
    PokemonLevelToken public lvlToken;
    StoneToken public stoneToken;

    struct Pokemon {
        string name;
        uint256 level;
        uint256 stage;
        //mapping(uint => string ) name;
    }

    uint256 public constant TOKEN_PRICE = 0.01 ether;

    uint256 internal _currentTokenId;
    mapping(address => mapping(uint256 => Pokemon)) internal _pokemonOf;

    modifier lvlUpdate(uint256 _tokenId) {
        uint256 pokemonLvl = lvlToken.balanceOf(msg.sender);
        _pokemonOf[msg.sender][_tokenId].level = pokemonLvl;

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
            msg.value >= TOKEN_PRICE,
            "Sending amount must be more than 0.01 ETH"
        );

        _mintPokemon(msg.sender);
    }

    function createPokemon(uint256 _tokenId) external {
        _createPokemon(_tokenId, random(), 1);
    }

    function createPokemon(
        uint256 _tokenId,
        uint256 _index,
        uint256 _stage
    ) external onlyOwner {
        _createPokemon(_tokenId, _index, _stage);
    }

    function evolution(uint256 _tokenId) external lvlUpdate(_tokenId) {
        Pokemon memory pokemon = _pokemonOf[msg.sender][_tokenId];
        require(ownerOf(_tokenId) == msg.sender, "You don't have PKMN token");

        if (_evolutionReq(_tokenId)) {
            if (_compareStrings(pokemon.name, pokemonNames(1, 0))) {}
        }
        // token exist, tokenlvl >= evolution requirement
        _deletePokemon(msg.sender, _tokenId);
        _mintPokemon(msg.sender);
    }

    function currentTokenId() public view returns (uint256) {
        return _currentTokenId;
    }

    function pokemonNames(uint256 stage, uint256 index)
        public
        pure
        returns (string memory)
    {
        string[3] memory firstStageNames = ["Polywag", "Onix", "Squirtle"];
        string[3] memory secondStageNames = [
            "Polywhirl",
            "Steelix",
            "Wartortle"
        ];
        string[3] memory thirdStageNames = [
            "Poliwrath",
            "Politoed",
            "Blastoise"
        ];
        if (stage == 1) {
            return firstStageNames[index];
        } else if (stage == 2) {
            return secondStageNames[index];
        } else {
            return thirdStageNames[index];
        }
    }

    function _createPokemon(
        uint256 _tokenId,
        uint256 _index,
        uint256 _stage
    ) internal {
        uint256 pokemonLvl = lvlToken.balanceOf(msg.sender);

        require(pokemonLvl > 0, "You don't have PLVL tokens");
        require(ownerOf(_tokenId) == msg.sender, "You don't have PKMN token");

        Pokemon memory pokemon = Pokemon({
            name: pokemonNames(_stage, _index),
            level: pokemonLvl,
            stage: _stage
        });

        _pokemonOf[msg.sender][_tokenId] = pokemon;
    }

    function _deletePokemon(address pokemonOwner, uint256 _tokenId) internal {
        require(
            _isApprovedOrOwner(pokemonOwner, _tokenId),
            "Not an owner of token or approved for it"
        );
        _burn(_tokenId);

        delete _pokemonOf[pokemonOwner][_tokenId];
    }

    function _mintPokemon(address to) private {
        safeMint(to, _currentTokenId);
        _currentTokenId++;
    }

    function _evolutionReq(uint256 _tokenId) private view returns (bool) {
        Pokemon memory pokemon = _pokemonOf[msg.sender][_tokenId];

        //
        if (pokemon.level > 0) {
            return true;
        } else {
            if (pokemon.stage > 0) {
                return false;
            }
        }
    }

    function _compareStrings(string memory x, string memory y)
        private
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(x)) == keccak256(abi.encodePacked(y));
    }

    function _lvlTokensMultiplier() private view returns (uint256) {
        return 10**lvlToken.decimals();
    }
}
