// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IPokemonNames {
    function firstStageNames(uint256 _index)
        external
        pure
        returns (string memory);

    function secondStageNames(uint256 _index)
        external
        pure
        returns (string memory);

    function thirdStageNames(uint256 _index)
        external
        pure
        returns (string memory);
}
