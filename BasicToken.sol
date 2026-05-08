// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BasicToken
 * @dev Professional ERC20 Token with Minting and Burning capabilities.
 */
contract BasicToken is ERC20, ERC20Burnable, Ownable {
    
    error MaxSupplyExceeded();

    uint256 public immutable maxSupply;

    /**
     * @notice Constructor to initialize the token
     * @param name_ Token name
     * @param symbol_ Token symbol
     * @param maxSupply_ Maximum total supply of tokens
     * @param initialOwner Address of the initial owner
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        address initialOwner
    ) ERC20(name_, symbol_) Ownable(initialOwner) {
        maxSupply = maxSupply_;
    }

    /**
     * @notice Mint new tokens (Owner only)
     * @param to Address to receive the minted tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        if (totalSupply() + amount > maxSupply) revert MaxSupplyExceeded();
        _mint(to, amount);
    }
}
