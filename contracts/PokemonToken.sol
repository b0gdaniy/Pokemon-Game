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
        PokemonsNum index;
        uint256 level;
        uint256 stage;
    }

    uint256 public constant TOKEN_PRICE = 0.01 ether;
    uint256 public constant CREATE_POKEMON_PRICE = 5;
    uint256 public constant STAGE_ONE_POKEMON_PRICE = 20;
    uint256 public constant STAGE_TWO_POKEMON_PRICE = 40;

    uint256 internal _currentTokenId;
    mapping(address => mapping(uint256 => Pokemon)) internal _pokemonOf;

    modifier lvlUpdate(uint256 _tokenId) {
        uint256 _pokemonLvl = pokemonLvl();
        _pokemonOf[msg.sender][_tokenId].level = _pokemonLvl;

        _;
    }

    modifier reqOwner(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "You don't have PKMN token");
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

        _mintToken(msg.sender);
    }

    function createPokemon(uint256 _tokenId)
        external
        reqOwner(_tokenId)
        lvlUpdate(_tokenId)
    {
        uint256 _pokemonLvl = pokemonLvl();
        require(_pokemonLvl > 0, "You don't have PLVL tokens");
        _createPokemon(_tokenId, PokemonsNum(random(5)), 1, _pokemonLvl);
    }

    function createPokemonWithIndexAndStage(
        uint256 _tokenId,
        uint256 _index,
        uint256 _stage,
        uint256 _lvl
    ) external onlyOwner {
        _createPokemon(_tokenId, PokemonsNum(_index), _stage, _lvl);
    }

    function evolution(uint256 _tokenId)
        external
        reqOwner(_tokenId)
        lvlUpdate(_tokenId)
    {
        Pokemon memory pokemon = myPokemon(_tokenId);

        uint256 _stage = pokemon.stage;
        require(_stage < 3, "Your pokemon can no longer evolve");

        PokemonsNum _index = pokemon.index;
        uint256 currentLevel = pokemon.level;

        _deletePokemon(msg.sender, _tokenId);

        _mintToken(msg.sender);

        _createPokemon(_currentTokenId - 1, _index, _stage + 1, currentLevel);
    }

    function currentTokenId() public view returns (uint256) {
        return _currentTokenId;
    }

    function pokemonLvl() public view returns (uint256) {
        return lvlToken.balanceOf(msg.sender) / _lvlTokensMultiplier();
    }

    function myPokemon(uint256 _tokenId) public view returns (Pokemon memory) {
        return _pokemonOf[msg.sender][_tokenId];
    }

    function pokemonNames(PokemonsNum _index, uint256 _stage)
        public
        pure
        returns (string memory)
    {
        string[5] memory firstStageNames = [
            "Bulbasaur",
            "Charmander",
            "Squirtle",
            "Oddish",
            "Poliwag"
        ];
        string[5] memory secondStageNames = [
            "Ivysaur",
            "Charmeleon",
            "Wartortle",
            "Gloom",
            "Poliwhirl"
        ];
        string[7] memory thirdStageNames = [
            "Venusaur",
            "Charizard",
            "Blastoise",
            "Vileplume",
            "Poliwrath",
            "Bellossom",
            "Politoed"
        ];

        if (_stage == 2) {
            return secondStageNames[uint256(_index)];
        } else if (_stage == 3) {
            return thirdStageNames[uint256(_index)];
        }
        return firstStageNames[uint256(_index)];
    }

    function evoPrice(PokemonsNum _index, uint256 _stage)
        public
        pure
        returns (uint256)
    {
        if (!_isStraightFlowEvo(_index, _stage)) {
            return 0;
        } else if (_stage == 1) {
            return STAGE_ONE_POKEMON_PRICE;
        } else if (_stage == 2) {
            return STAGE_TWO_POKEMON_PRICE;
        } else {
            return CREATE_POKEMON_PRICE;
        }
    }

    function _createPokemon(
        uint256 _tokenId,
        PokemonsNum _index,
        uint256 _stage,
        uint256 _lvl
    ) internal {
        require(ownerOf(_tokenId) == msg.sender, "You don't have PKMN token");

        uint256 _evoPrice = evoPrice(_index, _stage);

        if (_evoPrice > 0) {
            _straightFlowEvo(_lvl, _evoPrice);
        } else {
            _index = _stoneEvo();
        }

        Pokemon memory pokemon = Pokemon({
            name: pokemonNames(_index, _stage),
            index: _index,
            level: _lvl,
            stage: _stage
        });

        _pokemonOf[msg.sender][_tokenId] = pokemon;
    }

    function _straightFlowEvo(uint256 level, uint256 price) private {
        require(level >= price, "You need more level to evolve");
        lvlToken.burn(price * _lvlTokensMultiplier());
    }

    function _stoneEvo() private returns (PokemonsNum) {
        require(
            stoneToken.balanceOf(msg.sender) > 0,
            "You don't have stone for evolve"
        );

        StoneType _stoneType = stoneToken.stoneType(msg.sender);
        stoneToken.deleteStone(msg.sender, stoneToken.stoneId(msg.sender));

        if (_stoneType == StoneType.Leaf) {
            return PokemonsNum.Vileplume;
        } else if (_stoneType == StoneType.Sun) {
            return PokemonsNum.Bellosom;
        } else if (_stoneType == StoneType.Water) {
            return PokemonsNum.Poliwrath;
        } else {
            return PokemonsNum.Politoed;
        }
    }

    function _deletePokemon(address pokemonOwner, uint256 _tokenId) private {
        require(
            _isApprovedOrOwner(pokemonOwner, _tokenId),
            "Not an owner of token or approved for it"
        );
        _burn(_tokenId);

        delete _pokemonOf[pokemonOwner][_tokenId];
    }

    function _mintToken(address to) private {
        safeMint(to, _currentTokenId);
        _currentTokenId++;
    }

    function _lvlTokensMultiplier() private view returns (uint256) {
        return 10**lvlToken.decimals();
    }

    function _isStraightFlowEvo(PokemonsNum _index, uint256 _stage)
        private
        pure
        returns (bool)
    {
        if (
            _stage <= 1 ||
            _index == PokemonsNum.Venusaur ||
            _index == PokemonsNum.Charizard ||
            _index == PokemonsNum.Blastoise
        ) {
            return true;
        } else {
            return false;
        }
    }
}

// function _compareStrings(string memory x, string memory y)
//     private
//     pure
//     returns (bool)
// {
//     return keccak256(abi.encodePacked(x)) == keccak256(abi.encodePacked(y));
// }
