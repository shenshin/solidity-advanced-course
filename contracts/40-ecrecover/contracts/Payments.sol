// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Payments is Ownable {
    mapping(uint256 => bool) nonces;

    constructor() payable {
        require(
            msg.value > 0,
            'deployer should put some funds on the contract balance'
        );
    }

    function claim(
        uint256 _amount,
        uint256 _nonce,
        bytes memory _signature
    ) external {
        require(!nonces[_nonce], 'nonce already used!');
        nonces[_nonce] = true;

        // restore signed message
        bytes32 message = withPrefix(
            keccak256(
                abi.encodePacked(msg.sender, _amount, _nonce, address(this))
            )
        );

        require(
            recoverSigner(message, _signature) == owner(),
            'invalid signature'
        );

        payable(msg.sender).transfer(_amount);
    }

    function withPrefix(bytes32 _hash) private pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked('\x19Ethereum Signed Message:\n32', _hash)
            );
    }

    function recoverSigner(
        bytes32 _message,
        bytes memory _signature
    ) private pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_signature);
        return ecrecover(_message, v, r, s);
    }

    function splitSignature(
        bytes memory _signature
    ) private pure returns (uint8 v, bytes32 r, bytes32 s) {
        // length is 65, because first 32 is r, next 32 is s and the last 1 byte is v
        require(_signature.length == 65, 'wrong signature length');
        assembly {
            // add 32 bytes to the beginning of the signature pointer and load a word (32 bytes)
            // first 32 bytes is a sig length prefix which we are not interested in here
            r := mload(add(_signature, 32))
            // read next 32 bytes
            s := mload(add(_signature, 64))
            // get the first byte from the 32 byte long word
            v := byte(0, mload(add(_signature, 96)))
        }
        return (v, r, s);
    }
}
