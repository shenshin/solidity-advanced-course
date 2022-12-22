//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './ILogger.sol';

contract LogDemo {
    ILogger logger;

    constructor(address _Logger) {
        logger = ILogger(_Logger);
    }

    function payment(address _from, uint256 _number)
        public
        view
        returns (uint256)
    {
        return logger.getEntry(_from, _number);
    }

    receive() external payable {
        logger.log(msg.sender, msg.value);
    }
}
