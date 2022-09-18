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

    constructor() NFTTemplate("Stone", "STN") {}

    receive() external payable {
        require(msg.value >= 0.5 ether, "Amount must >= 0.5 ETH");

        _mintStone(msg.sender);
    }

    function safeMint(address to, uint256 tokenId) public override onlyOwner {
        require(balanceOf(msg.sender) == 0, "You already have STN");
        super.safeMint(to, tokenId);
    }

    function deleteStone(uint256 _tokenId) public {
        stnExists(tx.origin);
        require(_stoneOf[tx.origin].tokenId == _tokenId, "Not an owner");

        _burn(_tokenId);

        delete _stoneOf[tx.origin];
    }

    function createStone() external {
        _createStone(StoneType(random(4)));
    }

    function stoneType(address stoneOwner) public view returns (StoneType) {
        stnExists(stoneOwner);
        return _stoneOf[stoneOwner].stoneType;
    }

    function stoneId(address stoneOwner) public view returns (uint256) {
        stnExists(stoneOwner);
        return _stoneOf[stoneOwner].tokenId;
    }

    function stoneNameOf(address stoneOwner)
        public
        view
        returns (string memory)
    {
        stnExists(stoneOwner);
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

    function _mintStone(address tokenOwner) private {
        require(balanceOf(tokenOwner) == 0, "You already have STN");
        _safeMint(tokenOwner, currentId);

        _stoneOf[tokenOwner].tokenId = currentId;
        currentId++;
    }

    function stnExists(address stnOwner) private view {
        require(
            bytes(_stoneOf[stnOwner].name).length > 0,
            "Address haven't STN"
        );
    }
}
