// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IHoneyLogger {
    event Log(address caller, uint256 amount, uint256 actionCode);

    function log(
        address _caller,
        uint256 _amount,
        uint256 _actionCode
    ) external;
}
