// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";

contract StoneToken is NFTTemplate {
    struct Stone {
        uint256 tokenId;
        string name;
        StoneType stoneType;
    }

    uint256 private currentId;
    mapping(address => Stone) private _stoneOf;

    modifier stoneExists(address stoneOwner) {
        require(
            bytes(_stoneOf[stoneOwner].name).length > 0,
            "Address haven't STN"
        );

        _;
    }

    modifier isNotMinted(address tokenOwner) {
        require(balanceOf(tokenOwner) == 0, "You already have STN");
        _;
    }

    constructor() NFTTemplate("Stone", "STN") {}

    receive() external payable {
        require(msg.value >= 0.5 ether, "Amount must >= 0.5 ETH");

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
        require(_stoneOf[tx.origin].tokenId == _tokenId, "Not an owner");

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
        require(balanceOf(msg.sender) > 0, "You haven't STN");
        require(
            bytes(_stoneOf[msg.sender].name).length == 0,
            "You already have Stone"
        );

        _stoneOf[msg.sender].name = stoneNames(_index);
        _stoneOf[msg.sender].stoneType = _index;
    }

    function _mintStone(address tokenOwner) private isNotMinted(tokenOwner) {
        _safeMint(tokenOwner, currentId);

        _stoneOf[tokenOwner].tokenId = currentId;
        currentId++;
    }
}
