// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/token/ERC20/IERC20.sol";

contract CrowdFund {
    event Launch(uint id, address indexed creator, uint goal, uint startAt, uint endAt);
    event Cancel(uint id);
    event Pledge(uint id, address indexed caller, uint amount);
    event Unpledge(uint id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint indexed id, address indexed caller, uint amount);

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    modifier onlyOwner(uint _id) {
        require(msg.sender == campaigns[_id].creator, "Only campaign creator can call this function.");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "Starting point can not be in the past.");
        require(_endAt >= _startAt, "Ending point can not be greater than starting point.");
        require(_endAt <= block.timestamp + 90 days, "Ending point can not be greater than max duration.");
        
        count += 1;
        campaigns[count] = Campaign(msg.sender, _goal, 0, _startAt, _endAt, false);
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel(uint _id) external onlyOwner(_id) {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp < campaign.startAt, "Already started.");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign is not started.");
        require(block.timestamp <= campaign.endAt, "Campaign has ended.");

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "Campaign has ended.");
        require(pledgedAmount[_id][msg.sender] > _amount, "Insufficient funds.");
        
        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external onlyOwner(_id) {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "Campaign has not ended.");
        require(campaign.pledged >= campaign.goal, "Campaign couldn't reach the goal.");
        require(!campaign.claimed, "Already claimed!");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);
        emit Claim(_id);
    }

    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "Campaign has not ended.");
        require(campaign.pledged < campaign.goal, "Campaign reached the goal.");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);
        emit Refund(_id, msg.sender, bal);
    }
}