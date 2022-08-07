//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Merkle {
  bytes32[] public hashes;
  string[4] transactions = [
    "TX1: sdhfdsdfhds",
    "TX2: fdghjkhjasr",
    "TX3: mgoegvksjgjh",
    "TX4: ngyn39gnsivn"
  ];

  constructor() {
    for (uint i = 0; i < transactions.length; i++) {
      hashes.push(makeHash(transactions[i]));
    }
    uint count = transactions.length;
    uint offset = 0;
    while (count > 0) {
      for (uint i = 0; i < count - 1; i += 2) {
        hashes.push(keccak256(
          abi.encodePacked(
            hashes[offset + i], hashes[offset + i + 1]
          )
        ));
      }
      offset += count;
      count /= 2;
    }
  }

  function verify(string memory _tx, uint _index, bytes32 _root, bytes32[] memory proof) public pure returns(bool) {
    bytes32 hash = makeHash(_tx);
    for (uint i = 0; i < proof.length; i++) {
      bytes32 element = proof[i];
      // index is even or odd
      if (_index % 2 == 0) {
        hash = keccak256(abi.encodePacked(hash, element));
      } else {
        hash = keccak256(abi.encodePacked(element, hash));
      }
      _index /= 2;
    }
    return hash == _root;
  }

  function encode(string memory input) public pure returns(bytes memory) {
    return abi.encodePacked(input);
  }

  function makeHash(string memory input) public pure returns(bytes32) {
    return keccak256(encode(input));
  }
}