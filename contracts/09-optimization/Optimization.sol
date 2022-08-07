//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Optimized {
    // 1. don't assign default values
    // takes 67066 gas
    uint demo; 

    // 2. group vars together by size
    // takes 113512 gas
    uint128 a = 1; // packing 128 bit vars together (two 128 bit vars sequentially)
    uint128 b = 1; 
    uint256 c = 1;

    // 3. cheaper is to use uint256 instead of e.g. uint8
    // 89240 gas
    uint256 demo1 = 1; 

    // 3a. however arrays are the opposite: the less size - the cheaper
    // because numbers are being packed to the less size
    // 127260 gas
    uint8[] demo2 = [1, 2, 3];

    // 4. use static value at the initialization time if possible
    // better to hardcode values known in advance
    // 114791 gas used
    bytes32 public hash = 0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658;

    // 5. don't initialize intermediate variables unless absolutely necessary
    mapping(address => uint256) payments;
    // 23501 gas
    function pay() external payable {
         require(msg.sender != address(0), "zero address");
         payments[msg.sender] = msg.value;
    }

    // 6. mappings are much cheaper than arrays. 
    // use them wherever possible instead
    mapping(address => uint256) payments1;

    // 7. fixed size arrays are cheaper than dynamic
    uint[10] payments2;

    // 8. Don't create many little functions calling each other
    // unlike in all other languages
    // if possible, do not make calls to other functions espec from other contracts
    uint cc = 5;
    uint dd;
     // 46124 gas
     function calc() public {
         uint aa = 1 + cc;
         uint bb = 2 * cc;
         dd = aa + bb;
     }

    // 9. Don't use long strings - 32 bytes max

    // 10. dont't modify the same state var many times
    uint public result = 1;
    // input [1,2,3], gas: 29749
    function doWork(uint[] memory data) public {
        uint temp = 1;
        for (uint i = 0; i < data.length; i++) {
            temp *= data[i];
        }
        result = temp;
    }
 }

contract NonOptimized {
    // 1.
    // 69324 gas
    uint demo = 0; 

    // 2.
    uint128 a = 1; // without packing 
    uint256 c = 1; // takes 135362 gas
    uint128 b = 1;

    // 3.
    // 89641 gas !!!!!!!! 
     uint8 demo1 = 1; 

    // 3a
    // 158612 gas
     uint256[] demo2 = [1, 2, 3];

    // 4.
    // 116440 gas used
     bytes32 public hash = keccak256(
         abi.encodePacked("test")
     ); 

    // 5.
     mapping(address => uint256) payments;
    // 23698 gas
     function pay() external payable {
    //     // don't do
         address _from = msg.sender;
         require(_from != address(0), "zero address");
         payments[_from] = msg.value;
     }

    // 6.
    uint[] payments1;

    // 7.
    uint[] payments2;

    // 8. Don't create many little functions calling each other
     uint cc = 5;
     uint dd;
     // 46158 gas
     function calc() public {
         uint aa = 1 + cc;
         uint bb = 2 * cc;
         call2(aa, bb);
     }
     function call2(uint aa, uint bb) private {
         dd = aa + bb;
     }

    // 9.

    // 10. dont't modify the same state var many times
    uint public result = 1;
    // input [1,2,3] gas: 30179
    function doWork(uint[] memory data) public {
        for (uint i = 0; i < data.length; i++) {
            result *= data[i];
        }
    }
}