// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @title IPokemonNames
 * @author Bohdan Pukhno
 * @dev Interface of Pokemon Names contract.
 */
interface IPokemonNames {
    /**
     * @dev Returns first stage name by `index`.
     */
    function firstStageNames(uint256 _index)
        external
        pure
        returns (string memory);

    /**
     * @dev Returns second stage name by `index`.
     */
    function secondStageNames(uint256 _index)
        external
        pure
        returns (string memory);

    /**
     * @dev Returns third stage name by `index`.
     */
    function thirdStageNames(uint256 _index)
        external
        pure
        returns (string memory);
}
