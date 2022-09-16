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

    modifier tokenExists(address stoneOwner) {
        string memory _name = _stoneOf[stoneOwner].name;
        require(bytes(_name).length > 0, "You don't have STN token");
        _;
    }

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
        _createStone(StoneType(random(4)));
    }

    function createStoneWithIndex(StoneType _index) external onlyOwner {
        _createStone(_index);
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

    function stoneType(address stoneOwner)
        public
        view
        tokenExists(stoneOwner)
        returns (StoneType)
    {
        return _stoneOf[stoneOwner].stoneType;
    }

    function stoneId(address stoneOwner)
        public
        view
        tokenExists(stoneOwner)
        returns (uint256)
    {
        return _stoneOf[stoneOwner].tokenId;
    }

    function stoneNameOf(address stoneOwner)
        public
        view
        tokenExists(stoneOwner)
        returns (string memory)
    {
        return _stoneOf[stoneOwner].name;
    }

    function _createStone(StoneType _index) internal {
        require(balanceOf(msg.sender) > 0, "You don't have any STN tokens");

        uint256 _tokenId = _stoneOf[msg.sender].tokenId;

        Stone memory stone = Stone({
            tokenId: _tokenId,
            name: stoneNames(_index),
            stoneType: _index
        });

        _stoneOf[msg.sender] = stone;
    }

    function deleteStone(address stoneOwner, uint256 _tokenId)
        public
        tokenExists(stoneOwner)
    {
        require(
            _isApprovedOrOwner(stoneOwner, _tokenId),
            "Not an owner of token or approved for it"
        );
        _burn(_tokenId);
    }
}
