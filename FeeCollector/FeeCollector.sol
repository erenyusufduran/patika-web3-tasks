// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FeeCollector {
    address public owner;
    uint256 public balance;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() payable external {
        balance += msg.value;
    }

    function withdraw(uint amount, address payable destAddr) public onlyOwner {
        require(amount < balance, "Insufficient funds.");
        destAddr.transfer(amount);
        balance -= amount;
    }
}
