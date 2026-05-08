// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title PiggyBank
 * @dev A secure piggy bank contract, allowing deposits and a one-time withdrawal by the owner.
 */
contract PiggyBank is ReentrancyGuard {
    address public immutable owner;
    bool public isSmashed;

    event Deposited(address indexed sender, uint256 amount);
    event Smashed(uint256 totalAmount);

    error NotOwner();
    error AlreadySmashed();
    error TransferFailed();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier active() {
        if (isSmashed) revert AlreadySmashed();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable active {
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw all funds. Cannot be used again once smashed.
     */
    function smash() external onlyOwner active nonReentrant {
        isSmashed = true;
        uint256 balance = address(this).balance;
        
        emit Smashed(balance);
        
        (bool success, ) = owner.call{value: balance}("");
        if (!success) revert TransferFailed();
    }
}
