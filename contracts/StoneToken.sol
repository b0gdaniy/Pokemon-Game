// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";
import "./Structs/Stone.sol";

/**
 * @title Stone Token contract
 * @author Bohdan Pukhno
 * @dev Imlementation of ERC721 token contract.
 * @notice Stone Token creates for Pokemon Game, Stone needs for evolution of
 * some Pokemons with stone flow evolution.
 * Receives funds and creates one Stone token to sender.
 */
contract StoneToken is NFTTemplate {
    uint256 private currentId;
    mapping(address => Stone) private _stoneOf;

    /// @dev Needed to check is the `stoneOwner` has STN token.
    modifier stoneExists(address stoneOwner) {
        require(
            bytes(_stoneOf[stoneOwner].name).length > 0,
            "Address haven't STN"
        );
        _;
    }

    /**
     * @dev See {NFTTempate-constructor}.
     */
    constructor() NFTTemplate("Stone", "STN") {}

    /**
     * @dev Receives `msg.value` and mints STN token to `msg.sender`.
     * @notice Gives STN to `msg.sender`.
     */
    receive() external payable {
        require(msg.value >= 0.5 ether, "Amount must >= 0.5 ETH");

        _mintStone(msg.sender);
    }

    /**
     * @dev See {NFTTemplate-safeMint}.
     * Mins tokens to `to` with token id `tokenId`.
     *
     * REQUIREMENTS:
     * - `msg.sender` cant have STN
     */
    function safeMint(address to, uint256 tokenId) public override onlyOwner {
        require(balanceOf(msg.sender) == 0, "You already have STN");
        super.safeMint(to, tokenId);
    }

    /**
     * @dev Deletes Stone from `tx.origin` with token id `tokenId`.
     *
     * REQUIREMENTS:
     * - `tx.origin` must have STN,
     * - `tx.origin` must be an owner of token with `tokenId`
     */
    function deleteStone(uint256 _tokenId) public stoneExists(tx.origin) {
        require(_stoneOf[tx.origin].tokenId == _tokenId, "Not an owner");

        _burn(_tokenId);

        delete _stoneOf[tx.origin];
    }

    /**
     * @dev Creates Stone to `msg.sender` with random type.
     *
     * REQUIREMENTS:
     * - `msg.sender` must have STN,
     * - `msg.sender` mustn't have Stone
     */
    function createStone() external {
        _createStone(msg.sender, StoneType(random(4)));
    }

    /**
     * @dev Creates Stone to `to` with `index` type.
     *
     * REQUIREMENTS:
     * - `to` must have STN,
     * - `to` mustn't have Stone
     */
    function createStoneWithIndexTo(address _to, uint256 _index)
        external
        onlyOwner
    {
        _createStone(_to, StoneType(_index));
    }

    /**
     * @dev Returns Stone type of `stoneOwner`.
     *
     * REQUIREMENTS:
     * - `to` must have STN
     */
    function stoneType(address stoneOwner)
        public
        view
        stoneExists(stoneOwner)
        returns (StoneType)
    {
        return _stoneOf[stoneOwner].stoneType;
    }

    /**
     * @dev Returns Stone token id of `stoneOwner`.
     *
     * REQUIREMENTS:
     * - `to` must have STN
     */
    function stoneId(address stoneOwner)
        public
        view
        stoneExists(stoneOwner)
        returns (uint256)
    {
        return _stoneOf[stoneOwner].tokenId;
    }

    /**
     * @dev Returns Stone name of `stoneOwner`.
     *
     * REQUIREMENTS:
     * - `to` must have STN
     */
    function stoneNameOf(address stoneOwner)
        public
        view
        stoneExists(stoneOwner)
        returns (string memory)
    {
        return _stoneOf[stoneOwner].name;
    }

    ///@dev Returns Stone names with `stoneType` index.
    function stoneNames(StoneType _stoneType)
        public
        pure
        returns (string memory)
    {
        string[4] memory stoneTypes = [
            "Leaf Stone",
            "Sun Stone",
            "Water Stone",
            "Kings Rock"
        ];
        return stoneTypes[uint256(_stoneType)];
    }

    function _createStone(address _to, StoneType _index) internal {
        require(balanceOf(_to) > 0, "You haven't STN");
        require(
            bytes(_stoneOf[_to].name).length == 0,
            "You already have Stone"
        );

        _stoneOf[_to].name = stoneNames(_index);
        _stoneOf[_to].stoneType = _index;
    }

    function _mintStone(address tokenOwner) private {
        require(balanceOf(tokenOwner) == 0, "You already have STN");
        _safeMint(tokenOwner, currentId);

        _stoneOf[tokenOwner].tokenId = currentId;
        currentId++;
    }
}
