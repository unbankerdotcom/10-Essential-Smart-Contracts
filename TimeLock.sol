// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TimeLock
 * @dev Contract that locks executing an arbitrary transaction until a minimum delay has passed.
 */
contract TimeLock is Ownable {
    uint256 public constant MIN_DELAY = 1 days;
    uint256 public constant MAX_DELAY = 30 days;
    uint256 public constant GRACE_PERIOD = 14 days;

    event Queued(bytes32 indexed txId, address indexed target, uint256 value, string signature, bytes data, uint256 timestamp);
    event Executed(bytes32 indexed txId, address indexed target, uint256 value, string signature, bytes data, uint256 timestamp);
    event Cancelled(bytes32 indexed txId);

    error TimestampNotInRange();
    error AlreadyQueued();
    error NotQueued();
    error TimestampNotPassed();
    error TimestampExpired();
    error TxFailed();

    mapping(bytes32 => bool) public queued;

    constructor(address initialOwner) Ownable(initialOwner) {}

    receive() external payable {}

    function getTxId(address target, uint256 value, string calldata signature, bytes calldata data, uint256 timestamp) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, signature, data, timestamp));
    }

    function queue(address target, uint256 value, string calldata signature, bytes calldata data, uint256 timestamp) external onlyOwner returns (bytes32) {
        if (timestamp < block.timestamp + MIN_DELAY || timestamp > block.timestamp + MAX_DELAY) {
            revert TimestampNotInRange();
        }

        bytes32 txId = getTxId(target, value, signature, data, timestamp);
        if (queued[txId]) revert AlreadyQueued();

        queued[txId] = true;

        emit Queued(txId, target, value, signature, data, timestamp);
        return txId;
    }

    function execute(address target, uint256 value, string calldata signature, bytes calldata data, uint256 timestamp) external payable onlyOwner returns (bytes memory) {
        bytes32 txId = getTxId(target, value, signature, data, timestamp);
        if (!queued[txId]) revert NotQueued();
        if (block.timestamp < timestamp) revert TimestampNotPassed();
        if (block.timestamp > timestamp + GRACE_PERIOD) revert TimestampExpired();

        queued[txId] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory res) = target.call{value: value}(callData);
        if (!success) revert TxFailed();

        emit Executed(txId, target, value, signature, data, timestamp);
        return res;
    }

    function cancel(bytes32 txId) external onlyOwner {
        if (!queued[txId]) revert NotQueued();
        queued[txId] = false;
        emit Cancelled(txId);
    }
}
