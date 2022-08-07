//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Ownable {
  address public owner;
  
  modifier onlyOwner() {
    require(msg.sender == owner, "only owner allowed");
    _;
  }

  constructor() {
    owner = msg.sender;
  }
}