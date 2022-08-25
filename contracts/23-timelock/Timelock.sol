// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Timelock is Ownable {
    uint256 public constant MINIMUM_DELAY = 10 seconds;
    uint256 public constant MAXIMUM_DELAY = 5 days;
    uint256 public constant GRACE_PERIOD = 5 days;
    // txs in a queue
    mapping(bytes32 => bool) public queue;

    event Queued(bytes32 txId);
    event Discarded(bytes32 txId);
    event Executed(bytes32 txId);

    function addToQueue(
        address _to,
        string calldata _funcName,
        bytes calldata _data,
        uint256 _value,
        uint256 _timeStamp
    ) external onlyOwner returns (bytes32 txId) {
        // timestamp limitations
        require(
            _timeStamp > block.timestamp + MINIMUM_DELAY &&
                _timeStamp < block.timestamp + MAXIMUM_DELAY,
            'invalid timestamp'
        );
        txId = getTxId(_to, _funcName, _data, _value, _timeStamp);
        require(!queue[txId], 'already queued');
        queue[txId] = true;
        emit Queued(txId);
    }

    function discard(bytes32 _txId) external onlyOwner {
        require(queue[_txId], 'not queued');
        // sets to default value
        delete queue[_txId];
        emit Discarded(_txId);
    }

    function execute(
        address _to,
        string calldata _funcName,
        bytes calldata _data,
        uint256 _timeStamp
    ) external payable onlyOwner returns (bytes memory) {
        require(block.timestamp > _timeStamp, 'too early');
        require(_timeStamp + GRACE_PERIOD > block.timestamp, 'tx expired');
        bytes32 txId = getTxId(_to, _funcName, _data, msg.value, _timeStamp);
        require(queue[txId], 'not queued');
        delete queue[txId];

        bytes memory data;
        if (bytes(_funcName).length > 0) {
            data = abi.encodeWithSignature(_funcName, _data);
        } else {
            data = _data;
        }

        (bool success, bytes memory resp) = _to.call{value: msg.value}(data);
        require(success, 'execution failed');
        emit Executed(txId);
        return resp;
    }

    function getTxId(
        address _to,
        string calldata _funcName,
        bytes calldata _data,
        uint256 _value,
        uint256 _timeStamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_to, _funcName, _data, _value, _timeStamp));
    }
}
