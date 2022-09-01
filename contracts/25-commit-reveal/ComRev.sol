// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';

contract ComRev is Ownable {
    address[] public candidates = [
        0x930d889945bd85a2F8a39A3829857c24dB5cDd46,
        0x8BF2f24AfBb9dBE4F2a54FD72748FC797BB91F81,
        0xD478f3CE39cc5957b890C09EFE709AC7d4c282F8
    ];

    mapping(address => bytes32) public commits;
    mapping(address => uint256) public votes;
    bool votingStopped;

    function commitVote(bytes32 _hashedVote) external activeVoting(true) {
        // verify that voter has not commited his choice yet
        require(
            commits[msg.sender] == bytes32(0),
            'you have already commited your vote'
        );

        commits[msg.sender] = _hashedVote;
    }

    function revealVote(address _candidate, bytes32 _secret)
        external
        activeVoting(false)
    {
        bytes32 commit = keccak256(
            abi.encodePacked(_candidate, _secret, msg.sender)
        );
        require(commit == commits[msg.sender], 'invalid parameters');

        delete commits[msg.sender];

        votes[_candidate] += 1;
    }

    function stopVoting() external onlyOwner activeVoting(true) {
        votingStopped = true;
    }

    function startVoting() external onlyOwner activeVoting(false) {
        votingStopped = false;
    }

    modifier activeVoting(bool _state) {
        if (_state) {
            require(!votingStopped, 'voting was already stopped');
        } else {
            require(votingStopped, 'voting was already started');
        }
        _;
    }
}
