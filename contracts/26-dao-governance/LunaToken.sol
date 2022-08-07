// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// owners of this tokens can vote
// the more Lunas you have, the more weight your vote has
contract LunaToken is ERC20 {
  constructor() ERC20("LunaToken", "LUN") {
    _mint(msg.sender, 1000);
  }
}