// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PokemonLevelToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("PokemonLevel", "PLVL") Ownable() {}

    /**
     * @dev Receives `msg.value` and mints `msg.value` tokens to `msg.sender`.
     * @notice Level up to Pokemon.
     */
    receive() external payable {
        _mint(msg.sender, msg.value * 10**decimals());
    }

    /**
     * @dev Withdraws all funds in contract.
     *
     * REQUIREMENTS:
     * - The caller must be an owner of this contract.
     */
    function withdrawAll() external onlyOwner {
        _withdraw(address(this).balance);
    }

    /**
     * @dev Withdraws `_amount` funds in contract.
     *
     * REQUIREMENTS:
     * - The caller must be an owner of this contract.
     */
    function withdraw(uint256 _amount) external onlyOwner {
        _withdraw(_amount);
    }

    /**
     * @dev Minting `amount` of tokens to `to`.
     *
     * REQUIREMENTS:
     * - The caller must be an owner of this contract.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Burns tokens from `msg.sender` with amount `amount`.
     */
    function burn(uint256 amount) public override {
        _burn(tx.origin, amount);
    }

    function _withdraw(uint256 _amount) internal {
        require(address(this).balance > 0, "Not enough funds");
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Withdraw failed");
    }
}
