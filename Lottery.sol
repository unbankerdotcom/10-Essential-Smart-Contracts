// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Lottery (Commit-Reveal)
 * @dev A secure lottery using a commit-reveal scheme to prevent random number manipulation.
 */
contract Lottery {
    uint256 public constant TICKET_PRICE = 0.01 ether;
    uint256 public constant REVEAL_DURATION = 1 days;

    address public manager;
    uint256 public commitEndTime;
    uint256 public revealEndTime;
    
    mapping(address => bytes32) public commits;
    mapping(address => bool) public hasRevealed;
    address[] public players;
    
    uint256 private seed;
    bool public lotteryEnded;

    event Committed(address indexed player);
    event Revealed(address indexed player, uint256 secret);
    event WinnerSelected(address indexed winner, uint256 prize);

    error IncorrectPayment();
    error PhaseEnded();
    error PhaseNotEnded();
    error NotManager();
    error InvalidReveal();
    error AlreadyCommitted();
    error TransferFailed();

    constructor(uint256 _commitDuration) {
        manager = msg.sender;
        commitEndTime = block.timestamp + _commitDuration;
        revealEndTime = commitEndTime + REVEAL_DURATION;
    }

    function commit(bytes32 dataHash) external payable {
        if (block.timestamp >= commitEndTime) revert PhaseEnded();
        if (msg.value != TICKET_PRICE) revert IncorrectPayment();
        if (commits[msg.sender] != 0) revert AlreadyCommitted();

        commits[msg.sender] = dataHash;
        players.push(msg.sender);
        
        emit Committed(msg.sender);
    }

    function reveal(uint256 secret) external {
        if (block.timestamp < commitEndTime) revert PhaseNotEnded();
        if (block.timestamp >= revealEndTime) revert PhaseEnded();
        if (hasRevealed[msg.sender]) revert InvalidReveal();

        bytes32 dataHash = keccak256(abi.encodePacked(msg.sender, secret));
        if (commits[msg.sender] != dataHash) revert InvalidReveal();

        hasRevealed[msg.sender] = true;
        seed ^= secret; // Mix the secret into the seed

        emit Revealed(msg.sender, secret);
    }

    function pickWinner() external {
        if (block.timestamp < revealEndTime) revert PhaseNotEnded();
        if (lotteryEnded) revert PhaseEnded();
        if (msg.sender != manager) revert NotManager();

        lotteryEnded = true;
        
        if (players.length == 0) return;

        uint256 randomIndex = uint256(keccak256(abi.encodePacked(seed, block.timestamp))) % players.length;
        address winner = players[randomIndex];
        uint256 prize = address(this).balance;

        emit WinnerSelected(winner, prize);
        
        (bool success, ) = winner.call{value: prize}("");
        if (!success) revert TransferFailed();
    }
}
