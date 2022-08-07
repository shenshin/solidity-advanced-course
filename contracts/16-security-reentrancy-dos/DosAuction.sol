//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract DosAuction {
  mapping(address => uint) public bidders;
  address[] public allBidders;
  uint public refundProgress;

  function bid() external payable {
    // require(msg.sender.code.length == 0, "no bids from smart contracts");
    bidders[msg.sender] += msg.value;
    allBidders.push(msg.sender);
  }

  // push - don't use! use pull approach instead
  function refund() external {
    for (uint i = refundProgress; i < allBidders.length; i ++) {
      address bidder = allBidders[i];
      (bool success,) = bidder.call{ value: bidders[bidder] }("");
      require(success, "failed!");
      // instead of require:
      /*
      if (!success) {
        failedRefunds.push(bidder);
      }
       */
      refundProgress++;
    }
  }
}