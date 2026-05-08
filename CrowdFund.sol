// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title CrowdFund
 * @dev A professional ERC20 crowdfunding contract.
 */
contract CrowdFund is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    address public immutable creator;
    uint256 public immutable goal;
    uint32 public immutable endAt;
    
    uint256 public pledged;
    mapping(address => uint256) public pledgedAmount;
    bool public claimed;

    event Pledged(address indexed caller, uint256 amount);
    event Unpledged(address indexed caller, uint256 amount);
    event Claimed(uint256 amount);
    event Refunded(address indexed caller, uint256 amount);

    error InvalidTimestamp();
    error CampaignEnded();
    error CampaignNotEnded();
    error GoalNotReached();
    error GoalReached();
    error AlreadyClaimed();
    error NotCreator();

    constructor(address _token, uint256 _goal, uint32 _duration) {
        token = IERC20(_token);
        creator = msg.sender;
        goal = _goal;
        endAt = uint32(block.timestamp) + _duration;
    }

    function pledge(uint256 _amount) external nonReentrant {
        if (block.timestamp >= endAt) revert CampaignEnded();
        
        pledged += _amount;
        pledgedAmount[msg.sender] += _amount;
        token.safeTransferFrom(msg.sender, address(this), _amount);
        
        emit Pledged(msg.sender, _amount);
    }

    function unpledge(uint256 _amount) external nonReentrant {
        if (block.timestamp >= endAt) revert CampaignEnded();
        
        pledged -= _amount;
        pledgedAmount[msg.sender] -= _amount;
        token.safeTransfer(msg.sender, _amount);
        
        emit Unpledged(msg.sender, _amount);
    }

    function claim() external nonReentrant {
        if (msg.sender != creator) revert NotCreator();
        if (block.timestamp < endAt) revert CampaignNotEnded();
        if (pledged < goal) revert GoalNotReached();
        if (claimed) revert AlreadyClaimed();

        claimed = true;
        uint256 balance = pledged;
        token.safeTransfer(creator, balance);

        emit Claimed(balance);
    }

    function refund() external nonReentrant {
        if (block.timestamp < endAt) revert CampaignNotEnded();
        if (pledged >= goal) revert GoalReached();

        uint256 bal = pledgedAmount[msg.sender];
        pledgedAmount[msg.sender] = 0;
        token.safeTransfer(msg.sender, bal);

        emit Refunded(msg.sender, bal);
    }
}
