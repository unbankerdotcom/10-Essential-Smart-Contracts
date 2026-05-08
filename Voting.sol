// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Voting
 * @dev A generic ballot contract supporting delegation and robust state management.
 */
contract Voting is Ownable {
    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }

    struct Proposal {
        bytes32 name;
        uint256 voteCount;
    }

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    error AlreadyVoted();
    error NoVotingRight();
    error SelfDelegation();
    error LoopInDelegation();

    event Voted(address indexed voter, uint256 indexed proposalIndex, uint256 weight);
    event Delegated(address indexed from, address indexed to);

    constructor(bytes32[] memory proposalNames, address initialOwner) Ownable(initialOwner) {
        voters[initialOwner].weight = 1;
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    function giveRightToVote(address voter) external onlyOwner {
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "The voter already has voting rights.");
        voters[voter].weight = 1;
    }

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        if (sender.voted) revert AlreadyVoted();
        if (to == msg.sender) revert SelfDelegation();

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            if (to == msg.sender) revert LoopInDelegation();
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];

        emit Delegated(msg.sender, to);

        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint256 proposalIndex) external {
        Voter storage sender = voters[msg.sender];
        if (sender.weight == 0) revert NoVotingRight();
        if (sender.voted) revert AlreadyVoted();

        sender.voted = true;
        sender.vote = proposalIndex;
        proposals[proposalIndex].voteCount += sender.weight;

        emit Voted(msg.sender, proposalIndex, sender.weight);
    }

    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() external view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}
