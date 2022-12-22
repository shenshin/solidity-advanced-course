//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './ILogger.sol';

contract Logger is ILogger {
    mapping(address => uint256[]) payments;

    function log(address _from, uint256 _amount) public override {
        require(_from != address(0), 'zero address!');

        payments[_from].push(_amount);
    }

    function getEntry(address _from, uint256 _index)
        public
        view
        override
        returns (uint256)
    {
        return payments[_from][_index];
    }
}
