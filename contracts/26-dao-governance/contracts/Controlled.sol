// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

// s/c we are going to control by the governancy
contract Controlled is Ownable {
    string public message;
    mapping(address => uint256) public balances;

    function pay(string calldata _message) external payable onlyOwner {
        message = _message;
        balances[msg.sender] = msg.value;
    }
}
