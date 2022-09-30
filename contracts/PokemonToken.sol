// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";
import "./PokemonLevelToken.sol";
import "./StoneToken.sol";
import "./IPokemonNames.sol";
import "./Structs/Pokemon.sol";

/**
 * @title Pokemon Game token
 * @author Bohdan Pukhno
 * @dev Imlementation of ERC721 token contract.
 * @notice In the Pokemon Game, the user can level up by purchasing level tokens or crafting stone tokens if the user is lucky.
 * You need to expand the Pokemon Names, Stone Token, and Level Token first, then you can expand the Pokemon Token.
 */
contract PokemonToken is NFTTemplate {
    /// @dev Added for interaction with PLVL token contract.
    PokemonLevelToken public lvlToken;
    /// @dev Added for interaction with STN token contract.
    StoneToken public stoneToken;
    /// @dev Added and on it we can add more pokemon names.
    IPokemonNames public pokemonNames_;

    uint256 internal _currentTokenId;
    mapping(address => mapping(uint256 => Pokemon)) internal _pokemonOf;

    /// @dev Needed to check is the `_tokenId` owner is `msg.sender`.
    modifier isOwnersToken(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "You haven't this PKMN");
        _;
    }

    /**
     * @dev See {NFTTempate-constructor}.
     */
    constructor(
        PokemonLevelToken _lvlToken,
        StoneToken _stoneToken,
        IPokemonNames _pokemonNames
    ) NFTTemplate("Pokemon", "PKMN") {
        lvlToken = _lvlToken;
        stoneToken = _stoneToken;
        pokemonNames_ = _pokemonNames;
    }

    /**
     * @dev Received amount to mint Pokemon Token for `msg.sender`.
     *
     * REQUIREMENTS:
     * - `msg.value` must be equal or grater than 0.01 ETH
     */
    receive() external payable {
        require(msg.value >= 0.01 ether, "Amount must >= 0.01 ETH");

        _mintPokemonToken(msg.sender);
    }

    /**
     * @dev Creates a pokemon for `msg.sender`, with random Pokemon types. Started from 1st stage.
     *
     * REQUIREMENTS:
     * - `msg.sender` must have PLVL token to create
     */
    function createPokemon(uint256 _tokenId) external {
        require(pokemonLvl() > 0, "You haven't PLVL");
        _createPokemon(_tokenId, PokemonsNum(random(5)), 1);
    }

    /**
     * @dev Creates a pokemon for `msg.sender`, with `_index` Pokemon types. Started from 1st stage.
     * Needs for unit tests.
     *
     * REQUIREMENTS:
     * - `msg.sender` must be an owner of this contract
     * - `msg.sender` must have PLVL token to create
     */
    function createPokemonWithIndex(uint256 _tokenId, uint256 _index)
        external
        onlyOwner
    {
        require(pokemonLvl() > 0, "You haven't PLVL");
        _createPokemon(_tokenId, PokemonsNum(_index), 1);
    }

    /**
     * @dev Evolves pokemon for `msg.sender`, with `_index` Pokemon types.
     * Changed `_stage` to one more
     *
     * Needs for check in unit tests.
     *
     * REQUIREMENTS:
     * - `msg.sender` must be an owner of this contract
     * - `msg.sender` must have PLVL token to create
     */
    function evolution(uint256 _tokenId) external isOwnersToken(_tokenId) {
        uint256 _stage = myPokemon(_tokenId).stage;
        require(_stage < 4, "Pokemon can no longer evolve");

        PokemonsNum _index = myPokemon(_tokenId).index;

        _deletePokemon(msg.sender, _tokenId);

        _mintPokemonToken(msg.sender);

        _createPokemon(_currentTokenId - 1, _index, _stage + 1);
    }

    /**
     * @dev Returns lvl of `msg.sender`, generates from PLVL balance.
     */
    function pokemonLvl() public view returns (uint256) {
        return lvlToken.balanceOf(msg.sender) / _lvlTokensMultiplier();
    }

    /**
     * @dev Returns Pokemon of `msg.sender`.
     *
     * REQUIREMENTS:
     * - `msg.sender` must be an owner of `tokenId`
     */
    function myPokemon(uint256 _tokenId)
        public
        view
        isOwnersToken(_tokenId)
        returns (Pokemon memory)
    {
        return _pokemonOf[msg.sender][_tokenId];
    }

    /**
     * @dev Returns Pokemon index of `msg.sender`.
     *
     * REQUIREMENTS:
     * - `msg.sender` must be an owner of `tokenId`
     */
    function myPokemonIndex(uint256 _tokenId)
        public
        view
        isOwnersToken(_tokenId)
        returns (PokemonsNum)
    {
        return myPokemon(_tokenId).index;
    }

    /**
     * @dev Returns Pokemon name of `msg.sender`.
     *
     * REQUIREMENTS:
     * - `msg.sender` must be an owner of `tokenId`
     */
    function myPokemonName(uint256 _tokenId)
        public
        view
        isOwnersToken(_tokenId)
        returns (string memory)
    {
        return myPokemon(_tokenId).name;
    }

    /**
     * @dev Returns Pokemon stage of `msg.sender`.
     *
     * REQUIREMENTS:
     * - `msg.sender` must be an owner of `tokenId`
     */
    function myPokemonStage(uint256 _tokenId)
        public
        view
        isOwnersToken(_tokenId)
        returns (uint256)
    {
        return myPokemon(_tokenId).stage;
    }

    /**
     * @dev returns Pokemon names from {PokemonNames.sol} by `index` and `stage`.
     */
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
            _index = _stoneEvo(_index);
        }

        _pokemonOf[msg.sender][_tokenId].name = pokemonNames(_index, _stage);
        _pokemonOf[msg.sender][_tokenId].index = _index;
        _pokemonOf[msg.sender][_tokenId].stage = _stage;
    }

    function _straightFlowEvo(uint256 level, uint256 price) private {
        require(level >= price, "You need more level");

        lvlToken.burn(price * _lvlTokensMultiplier());
    }

    function _stoneEvo(PokemonsNum _index) private returns (PokemonsNum) {
        require(
            stoneToken.balanceOf(msg.sender) > 0,
            "You haven't STN for evolve"
        );

        StoneType _stoneType = stoneToken.stoneType(msg.sender);
        if (_index == PokemonsNum.Vileplume) {
            require(
                _stoneType == StoneType.Leaf || _stoneType == StoneType.Sun,
                "You dont have type for Oddish"
            );
        } else {
            require(
                _stoneType == StoneType.Water ||
                    _stoneType == StoneType.KingsRock,
                "You dont have type for Poliwag"
            );
        }
        stoneToken.deleteStone(stoneToken.stoneId(msg.sender));
        return
            _stoneType == StoneType.Leaf
                ? PokemonsNum.Vileplume
                : _stoneType == StoneType.Sun
                ? PokemonsNum.Bellosom
                : _stoneType == StoneType.Water
                ? PokemonsNum.Poliwrath
                : PokemonsNum.Politoed;
    }

    function _deletePokemon(address pokemonOwner, uint256 _tokenId) private {
        require(
            _isApprovedOrOwner(pokemonOwner, _tokenId),
            "Not an owner or approved for"
        );
        _burn(_tokenId);

        delete _pokemonOf[pokemonOwner][_tokenId];
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
            _stage <= 2 ||
            _index == PokemonsNum.Venusaur ||
            _index == PokemonsNum.Charizard ||
            _index == PokemonsNum.Blastoise;
    }
}
