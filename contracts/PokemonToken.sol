// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";
import "./PokemonLevelToken.sol";
import "./StoneToken.sol";
import "./PokemonNames.sol";

contract PokemonToken is NFTTemplate {
    PokemonLevelToken public lvlToken;
    StoneToken public stoneToken;
    PokemonNames public pokemonNames_;

    struct Pokemon {
        string name;
        uint256 stage;
        PokemonsNum index;
    }

    uint256 internal _currentTokenId;
    mapping(address => mapping(uint256 => Pokemon)) internal _pokemonOf;

    modifier isOwnersToken(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "You haven't this PKMN");
        _;
    }

    constructor(
        PokemonLevelToken _lvlToken,
        StoneToken _stoneToken,
        PokemonNames _pokemonNames
    ) NFTTemplate("Pokemon", "PKMN") {
        lvlToken = _lvlToken;
        stoneToken = _stoneToken;
        pokemonNames_ = _pokemonNames;
    }

    receive() external payable {
        require(msg.value >= 0.01 ether, "Amount must >= 0.01 ETH");
        //v

        _mintPokemonToken(msg.sender);
    }

    function createPokemon(uint256 _tokenId) external {
        require(pokemonLvl() > 0, "You haven't PLVL");
        _createPokemon(_tokenId, PokemonsNum(random(5)), 1);
    }

    function evolution(uint256 _tokenId) external isOwnersToken(_tokenId) {
        uint256 _stage = myPokemon(_tokenId).stage;
        require(_stage < 4, "Pokemon can no longer evolve");
        //v

        PokemonsNum _index = myPokemon(_tokenId).index;

        _deletePokemon(msg.sender, _tokenId);

        _mintPokemonToken(msg.sender);

        _createPokemon(_currentTokenId - 1, _index, _stage + 1);
    }

    function pokemonLvl() public view returns (uint256) {
        return lvlToken.balanceOf(msg.sender) / _lvlTokensMultiplier();
    }

    function myPokemon(uint256 _tokenId)
        public
        view
        isOwnersToken(_tokenId)
        returns (Pokemon memory)
    {
        return _pokemonOf[msg.sender][_tokenId];
    }

    function pokemonNames(PokemonsNum _index, uint256 _stage)
        public
        view
        returns (string memory)
    {
        return
            _stage == 2
                ? pokemonNames_.secondStageNames(uint256(_index))
                : _stage == 3
                ? pokemonNames_.thirdStageNames(uint256(_index))
                : pokemonNames_.firstStageNames(uint256(_index));
    }

    function _createPokemon(
        uint256 _tokenId,
        PokemonsNum _index,
        uint256 _stage
    ) internal isOwnersToken(_tokenId) {
        uint256 evoPrice = !_isStraightFlowEvo(_index, _stage) ? 0 : _stage == 1
            ? 5
            : _stage == 2
            ? 20
            : 40;

        if (evoPrice > 0) {
            _straightFlowEvo(pokemonLvl(), evoPrice);
        } else {
            _index = _stoneEvo();
        }

        _pokemonOf[msg.sender][_tokenId].name = pokemonNames(_index, _stage);
        _pokemonOf[msg.sender][_tokenId].index = _index;
        _pokemonOf[msg.sender][_tokenId].stage = _stage;
    }

    function _straightFlowEvo(uint256 level, uint256 price) private {
        require(level >= price, "You need more level");
        //v
        lvlToken.burn(price * _lvlTokensMultiplier());
        //v
    }

    function _stoneEvo() private returns (PokemonsNum) {
        require(
            stoneToken.balanceOf(msg.sender) > 0,
            "You haven't STN for evolve"
        );
        //v

        StoneType _stoneType = stoneToken.stoneType(msg.sender);
        stoneToken.deleteStone(stoneToken.stoneId(msg.sender));
        //v
        return
            _stoneType == StoneType.Leaf
                ? PokemonsNum.Vileplume
                : _stoneType == StoneType.Sun
                ? PokemonsNum.Bellosom
                : _stoneType == StoneType.Water
                ? PokemonsNum.Poliwrath
                : PokemonsNum.Politoed;

        //v
    }

    function _deletePokemon(address pokemonOwner, uint256 _tokenId) private {
        require(
            _isApprovedOrOwner(pokemonOwner, _tokenId),
            "Not an owner or approved for"
        );
        //v
        _burn(_tokenId);

        delete _pokemonOf[pokemonOwner][_tokenId];
        //v
    }

    function _mintPokemonToken(address to) private {
        _safeMint(to, _currentTokenId);
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
        return
            _stage <= 1 ||
            _index == PokemonsNum.Venusaur ||
            _index == PokemonsNum.Charizard ||
            _index == PokemonsNum.Blastoise;
    }
}
