// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Multisig {
    // immutable can be set only once in constructor
    uint256 public immutable CONFIRMATIONS_REQUIRED;

    mapping(bytes32 => bool) public queue;
    mapping(bytes32 => uint256) public confirmations;
    // if the address has confirmed the tx
    mapping(bytes32 => mapping(address => bool)) public isConfirmed;
    mapping(address => bool) public isOwner;
    address[] public owners;

    event Queued(bytes32 txId, address sender);
    event Discarded(bytes32 txId, address sender);
    event Executed(bytes32 txId, address sender);
    event Confirmed(bytes32 txId, address sender);
    event CanceledConfirmation(bytes32 txId, address sender);

    function _checkIfQueued(bytes32 _txId) private view {
        require(queue[_txId], 'tx is not queued');
    }

    modifier isQueued(bytes32 _txId) {
        _checkIfQueued(_txId);
        _;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], 'not an owner');
        _;
    }

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
            owners.push(nextOwner);
        }
    }

    function addToQueue(
        address _to,
        bytes calldata _data,
        uint256 _value
    ) external onlyOwner {
        bytes32 txId = _getTxId(_to, _data, _value);
        require(!queue[txId], 'already queued');
        queue[txId] = true;
        emit Queued(txId, msg.sender);
    }

    function confirm(bytes32 _txId) external onlyOwner isQueued(_txId) {
        // verify that tx was not already confirmed by the sender
        require(!isConfirmed[_txId][msg.sender], 'you already confirmed');
        isConfirmed[_txId][msg.sender] = true;
        confirmations[_txId] += 1;
        emit Confirmed(_txId, msg.sender);
    }

    function cancelConfirmation(bytes32 _txId)
        external
        onlyOwner
        isQueued(_txId)
    {
        require(isConfirmed[_txId][msg.sender], 'not confirmed yet');
        isConfirmed[_txId][msg.sender] = false;
        confirmations[_txId] -= 1;
        emit CanceledConfirmation(_txId, msg.sender);
    }

    function discard(bytes32 _txId) external onlyOwner isQueued(_txId) {
        _removeFromQueue(_txId);
        emit Discarded(_txId, msg.sender);
    }

    function execute(
        address _to,
        bytes calldata _data,
        uint256 _value
    ) external payable onlyOwner {
        bytes32 txId = _getTxId(_to, _data, _value);
        _checkIfQueued(txId);

        require(
            confirmations[txId] >= CONFIRMATIONS_REQUIRED,
            'not enough confirmations'
        );
        require(
            address(this).balance >= _value,
            'insufficient funds for the tx'
        );

        bool success;
        if (_data.length > 0) {
            (success, ) = _to.call{value: _value}(_data);
        } else {
            success = payable(_to).send(_value);
        }
        require(success, 'execution failed');

        _removeFromQueue(txId);
        emit Executed(txId, msg.sender);
    }

    receive() external payable {}

    function _removeFromQueue(bytes32 _txId) private {
        delete queue[_txId];
        _clearConfirmations(_txId);
    }

    function _clearConfirmations(bytes32 _txId) private {
        for (uint256 i = 0; i < owners.length; i++) {
            delete isConfirmed[_txId][owners[i]];
        }
        delete confirmations[_txId];
    }

    function _getTxId(
        address _to,
        bytes calldata _data,
        uint256 _value
    ) private pure returns (bytes32) {
        return keccak256(abi.encode(_to, _data, _value));
    }
}
