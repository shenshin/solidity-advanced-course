//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './ERC20.sol';

contract MeowToken is ERC20 {
    constructor(address shop) ERC20('Meow Token', 'MEO', 10**6, shop) {}
}
