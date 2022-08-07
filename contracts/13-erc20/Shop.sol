//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./MeowToken.sol";
import "./Ownable.sol";

contract Shop is Ownable {
  IERC20 public acceptedToken;

  // event Bought(address indexed buyer, uint amount);
  // event Sold(address indexed seller, uint amount);

  constructor() {
    acceptedToken = new MeowToken(address(this));
    owner = msg.sender;
  }

  function sell(uint amount) external {
    require(amount > 0 && acceptedToken.balanceOf(msg.sender) >= amount, "incorrect ammount");

    uint allowance = acceptedToken.allowance(msg.sender, address(this));
    require(allowance >= amount, "check allowance");

    acceptedToken.transferFrom(msg.sender, address(this), amount);
    payable(msg.sender).transfer(amount);
  }

  function tokenBalance() public view returns(uint) {
    return acceptedToken.balanceOf(address(this));
  }

  receive() external payable {
    uint tokensToBuy = msg.value; // 1 wei = 1 MEO
    require(tokensToBuy > 0, "not enough funds");

    require(tokenBalance() >= tokensToBuy, "not enough tokens");

    acceptedToken.transfer(msg.sender, tokensToBuy);
    // emit Bought(msg.sender, tokensToBuy);
  }
}