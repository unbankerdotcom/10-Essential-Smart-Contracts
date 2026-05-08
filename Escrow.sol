// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Escrow
 * @dev A secure escrow contract for holding funds until conditions are met.
 */
contract Escrow is ReentrancyGuard {
    address public immutable buyer;
    address payable public immutable seller;
    address public immutable arbiter;

    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED }
    State public state;

    event Deposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, uint256 amountToSeller);
    event Refunded(address indexed arbiter, uint256 amountToBuyer);

    error InvalidState();
    error OnlyBuyer();
    error OnlyArbiter();
    error TransferFailed();

    modifier inState(State _state) {
        if (state != _state) revert InvalidState();
        _;
    }

    constructor(address _buyer, address payable _seller, address _arbiter) {
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
        state = State.AWAITING_PAYMENT;
    }

    function deposit() external payable inState(State.AWAITING_PAYMENT) {
        if (msg.sender != buyer) revert OnlyBuyer();
        state = State.AWAITING_DELIVERY;
        emit Deposited(msg.sender, msg.value);
    }

    function confirmDelivery() external nonReentrant inState(State.AWAITING_DELIVERY) {
        if (msg.sender != buyer) revert OnlyBuyer();
        state = State.COMPLETE;
        
        uint256 balance = address(this).balance;
        emit DeliveryConfirmed(msg.sender, balance);
        
        (bool success, ) = seller.call{value: balance}("");
        if (!success) revert TransferFailed();
    }

    function refundBuyer() external nonReentrant inState(State.AWAITING_DELIVERY) {
        if (msg.sender != arbiter) revert OnlyArbiter();
        state = State.REFUNDED;
        
        uint256 balance = address(this).balance;
        emit Refunded(msg.sender, balance);
        
        (bool success, ) = buyer.call{value: balance}("");
        if (!success) revert TransferFailed();
    }
}
