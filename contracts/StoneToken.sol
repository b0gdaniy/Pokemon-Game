// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";

contract StoneToken is NFTTemplate {
    struct Stone {
        uint256 tokenId;
        string name;
        StoneType stoneType;
    }

    uint256 public constant STONE_PRICE = 0.01 ether;
    uint256 private currentId;
    mapping(address => Stone) private _stoneOf;

    modifier stoneExists(address stoneOwner) {
        string memory _name = _stoneOf[stoneOwner].name;
        require(
            bytes(_name).length > 0,
            "This address doesn't have Stone token"
        );

        _;
    }

    modifier isNotMinted(address tokenOwner) {
        require(balanceOf(tokenOwner) == 0, "You already have stone token");
        _;
    }

    constructor() NFTTemplate("Stone", "STN") {}

    receive() external payable {
        require(
            msg.value >= STONE_PRICE,
            "The amount sent must be equal or greater than 0.01 ETH"
        );

        _mintStone(msg.sender);
    }

    function safeMint(address to, uint256 tokenId)
        public
        override
        onlyOwner
        isNotMinted(msg.sender)
    {
        super.safeMint(to, tokenId);
    }

    function deleteStone(uint256 _tokenId) public stoneExists(tx.origin) {
        uint256 tokenId = _stoneOf[tx.origin].tokenId;

        require(tokenId == _tokenId, "You are not an owner of this tokenId");

        _burn(_tokenId);

        delete _stoneOf[tx.origin];
    }

    function createStone() external {
        _createStone(StoneType(random(4)));
    }

    function createStoneWithIndex(StoneType _index) external onlyOwner {
        _createStone(_index);
    }

    function stoneType(address stoneOwner)
        public
        view
        stoneExists(stoneOwner)
        returns (StoneType)
    {
        return _stoneOf[stoneOwner].stoneType;
    }

    function stoneId(address stoneOwner)
        public
        view
        stoneExists(stoneOwner)
        returns (uint256)
    {
        return _stoneOf[stoneOwner].tokenId;
    }

    function stoneNameOf(address stoneOwner)
        public
        view
        stoneExists(stoneOwner)
        returns (string memory)
    {
        return _stoneOf[stoneOwner].name;
    }

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

    function _createStone(StoneType _index) internal {
        require(balanceOf(msg.sender) > 0, "You don't have any STN tokens");
        require(
            bytes(_stoneOf[msg.sender].name).length == 0,
            "You already have stone"
        );

        uint256 _tokenId = _stoneOf[msg.sender].tokenId;

        Stone memory stone = Stone({
            tokenId: _tokenId,
            name: stoneNames(_index),
            stoneType: _index
        });

        _stoneOf[msg.sender] = stone;
    }

    function _mintStone(address tokenOwner) private isNotMinted(tokenOwner) {
        _safeMint(tokenOwner, currentId);

        _stoneOf[tokenOwner].tokenId = currentId;
        currentId++;
    }
}
