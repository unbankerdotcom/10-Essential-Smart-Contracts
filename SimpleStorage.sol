// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleStorage
 * @dev Store and retrieve a value in a variable with access control.
 */
contract SimpleStorage is Ownable {
    uint256 private _data;

    event DataChanged(uint256 indexed newValue, address indexed updatedBy);

    error InvalidValue();

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Store `newValue` in the contract
     * @param newValue The new value to store
     */
    function set(uint256 newValue) external onlyOwner {
        if (newValue == 0) revert InvalidValue();
        _data = newValue;
        emit DataChanged(newValue, msg.sender);
    }

    /**
     * @notice Return the stored value
     * @return The currently stored uint256 value
     */
    function get() external view returns (uint256) {
        return _data;
    }
}
