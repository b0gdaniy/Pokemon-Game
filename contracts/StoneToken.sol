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

    constructor() NFTTemplate("Stone", "STN") {}

    receive() external payable {
        require(
            msg.value >= STONE_PRICE,
            "The amount sent must be equal or greater than 0.01 ETH"
        );

        safeMint(msg.sender, currentId);

        _stoneOf[msg.sender].tokenId = currentId;
        currentId++;
    }

    function createStone() external {
        _createStone(random(4));
    }

    function createStoneWithIndex(uint256 _index) external onlyOwner {
        _createStone(_index);
    }

    function stoneNames(uint256 _stoneType)
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
        return stoneTypes[_stoneType];
    }

    function stoneType(address stoneOwner) public view returns (StoneType) {
        return _stoneOf[stoneOwner].stoneType;
    }

    function stoneId(address tokenOwner) public view returns (uint256) {
        return _stoneOf[tokenOwner].tokenId;
    }

    function _createStone(uint256 _index) internal {
        require(balanceOf(msg.sender) > 0, "You don't have any STN tokens");

        uint256 _tokenId = _stoneOf[msg.sender].tokenId;

        Stone memory stone = Stone({
            tokenId: _tokenId,
            name: stoneNames(_index),
            stoneType: StoneType(_index)
        });

        _stoneOf[msg.sender] = stone;
    }

    function deleteStone(address owner, uint256 _tokenId) public {
        require(
            _isApprovedOrOwner(owner, _tokenId),
            "Not an owner of token or approved for it"
        );
        _burn(_tokenId);
    }
}
