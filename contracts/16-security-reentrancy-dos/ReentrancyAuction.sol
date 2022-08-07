//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract ReentrancyAuction {
  mapping(address => uint) public bidders;
  bool locked;

  modifier noReentrancy() {
    require(!locked, "No reentrancy");
    locked = true;
    _;
    locked = false;
  }

  function bid() external payable {
    bidders[msg.sender] += msg.value;
  }

// `pull` approach
  function refund() external {
    uint refundAmount = bidders[msg.sender];

    if (refundAmount > 0) {
      bidders[msg.sender] = 0;
      (bool success,) = msg.sender.call{value: refundAmount}("");
      require(success, "failed!");
    }
  }

  function currentBalance() external view returns(uint) {
    return address(this).balance;
  }
}