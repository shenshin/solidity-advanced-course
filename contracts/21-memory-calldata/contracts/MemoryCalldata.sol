// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MemoryCalldata {
    function readMemory(
        string memory /* _str */
    ) external pure returns (bytes32 data) {
        assembly {
            let pointer := mload(64)
            data := mload(sub(pointer, 32))
        }
    }

    function readCalldata(
        uint256[] calldata /* a */
    )
        external
        pure
        returns (
            bytes32 startIndex,
            bytes32 elementsCount,
            bytes32 firstElement
        )
    {
        assembly {
            startIndex := calldataload(4)
            elementsCount := calldataload(add(startIndex, 4))
            firstElement := calldataload(add(startIndex, 36))
        }
    }
}
