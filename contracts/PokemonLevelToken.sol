// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PokemonLevelToken is ERC20, Ownable {
    constructor() ERC20("PokemonLevel", "PLVL") {}

    /**
     * @dev Minting `msg.value` tokens to `msg.sender`.
     * @notice Level up to Pokemon.
     */
    receive() external payable {
        _mint(msg.sender, msg.value * 10**decimals());
    }

    /**
     * @dev Minting `amount` of tokens to `to`.
     *
     * REQUIREMENTS:
     * - The caller must be the owner of this contract.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
