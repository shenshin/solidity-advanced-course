// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract DataStorage {
    uint256 a = 123; // slot 0
    uint128 b = 10; // 1
    uint128 c = 20; // 1

    // keccak256(2)
    uint256[] arr; // 2

    // keccak256(key concat slot position)
    mapping(address => uint256) mapp; // 3

    constructor() {
        arr.push(10);
        arr.push(20);
        mapp[address(this)] = 100;
    }
}
