// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import './IHoneyLogger.sol';

contract Honeypot is IHoneyLogger {
    function log(
        address,
        uint256,
        uint256 _actionCode
    ) public pure {
        if (_actionCode == 2) {
            revert('honeypot!');
        }
    }
}
