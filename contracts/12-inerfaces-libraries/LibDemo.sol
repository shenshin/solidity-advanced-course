//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './ExtLib.sol';

contract LibDemo {
    // connecting library to the string type
    using StrExt for string;
    using ArrayExt for uint256[];

    function runnerArrays(uint256[] memory arr, uint256 el)
        public
        pure
        returns (bool)
    {
        return arr.inArray(el);
    }

    function runnerStrings(string memory str1, string memory str2)
        public
        pure
        returns (bool)
    {
        return str1.eq(str2);
    }
}
