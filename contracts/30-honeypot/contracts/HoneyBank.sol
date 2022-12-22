// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';
import './IHoneyLogger.sol';

contract HoneyLogger is IHoneyLogger {
    function log(
        address _caller,
        uint256 _amount,
        uint256 _actionCode
    ) public {
        emit Log(_caller, _amount, _actionCode);
    }
}

contract HoneyBank is Ownable {
    mapping(address => uint256) public balances;
    IHoneyLogger public logger;

    bool resuming;

    // substitute Logger with malicious one
    constructor(IHoneyLogger _logger) {
        logger = _logger;
    }

      function setLogger(IHoneyLogger _logger) public onlyOwner {
        logger = _logger;
    }

    function deposit() public payable {
        require(msg.value >= 1 ether);

        balances[msg.sender] += msg.value;
        // 0 - money is credited
        logger.log(msg.sender, msg.value, 0);
    }

    function withdraw() public {
        // 1 - money received by an honest inverstor
        // 2 - attacker is trying to withdraw money

        if (resuming) {
            _withdraw(msg.sender, 2);
        } else {
            resuming = true;
            _withdraw(msg.sender, 1);
        }
    }

    function _withdraw(address _initiator, uint256 _statusCode) internal {
        uint256 balance = balances[_initiator];
        (bool success, ) = _initiator.call{value: balance}('');

        require(success, 'Failed to withdraw Ether');

        balances[_initiator] = 0;

        logger.log(_initiator, balance, _statusCode);

        resuming = false;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
