// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';

contract TimelockMultisig {
    uint256 public constant MINIMUM_DELAY = 10 seconds;
    uint256 public constant MAXIMUM_DELAY = 5 days;
    uint256 public constant GRACE_PERIOD = 5 days;
    // txs in a queue
    mapping(bytes32 => bool) public queue;

    event Queued(bytes32 txId);
    event Discarded(bytes32 txId);
    event Executed(bytes32 txId);

    function _checkIfQueued(bytes32 _txId) private view {
        require(queue[_txId], 'tx is not queued');
    }

    modifier isQueued(bytes32 _txId) {
        _checkIfQueued(_txId);
        _;
    }

    // <multisig>
    mapping(address => bool) public isOwner;
    modifier onlyOwner() {
        require(isOwner[msg.sender], 'not an owner');
        _;
    }
    // immutable can be set only once in constructor
    uint256 public immutable CONFIRMATIONS_REQUIRED;

    mapping(bytes32 => uint256) public confirmations;
    // for the tx hash - if the address has confirmed the tx
    mapping(bytes32 => mapping(address => bool)) public isConfirmed;

    constructor(address[] memory _owners, uint256 _confirmationsRequired) {
        require(_confirmationsRequired <= _owners.length, 'not enough owners');
        CONFIRMATIONS_REQUIRED = _confirmationsRequired;
        for (uint256 i = 0; i < _owners.length; i++) {
            address nextOwner = _owners[i];
            require(
                nextOwner != address(0),
                "can't have zero address as an owner"
            );
            isOwner[nextOwner] = true;
        }
    }

    // </multisig>

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

    // multisig
    function confirm(bytes32 _txId) external onlyOwner isQueued(_txId) {
        // verify that tx was not already confirmed by the sender
        require(!isConfirmed[_txId][msg.sender], 'you already confirmed');
        isConfirmed[_txId][msg.sender] = true;
        confirmations[_txId] += 1;
    }

    function cancelConfirmation(bytes32 _txId)
        external
        onlyOwner
        isQueued(_txId)
    {
        require(isConfirmed[_txId][msg.sender], 'not confirmed yet');
        isConfirmed[_txId][msg.sender] = false;
        confirmations[_txId] -= 1;
    }

    // </multisig>

    function discard(bytes32 _txId) external onlyOwner isQueued(_txId) {
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

        _checkIfQueued(txId);

        // <multisig>
        require(
            confirmations[txId] >= CONFIRMATIONS_REQUIRED,
            'not enough confirmations'
        );
        // </multisig>

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
