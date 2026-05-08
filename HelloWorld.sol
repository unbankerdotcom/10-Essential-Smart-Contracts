// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title HelloWorld
 * @dev A professional, updatable greeting contract.
 */
contract HelloWorld {
    string private _greeting;
    address public immutable deployer;

    event GreetingUpdated(string oldGreeting, string newGreeting);

    error Unauthorized();
    error EmptyGreeting();

    constructor(string memory initialGreeting) {
        if (bytes(initialGreeting).length == 0) revert EmptyGreeting();
        _greeting = initialGreeting;
        deployer = msg.sender;
    }

    /**
     * @notice Update the greeting message
     * @param newGreeting The new string to set as the greeting
     */
    function setGreeting(string calldata newGreeting) external {
        if (msg.sender != deployer) revert Unauthorized();
        if (bytes(newGreeting).length == 0) revert EmptyGreeting();
        
        string memory oldGreeting = _greeting;
        _greeting = newGreeting;
        
        emit GreetingUpdated(oldGreeting, newGreeting);
    }

    /**
     * @notice Get the current greeting
     * @return The current greeting string
     */
    function getGreeting() external view returns (string memory) {
        return _greeting;
    }
}
