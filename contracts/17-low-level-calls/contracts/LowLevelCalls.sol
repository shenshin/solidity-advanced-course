//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract MyContract {
    address otherContract;
    bytes3 public color;

    constructor(address _otherContract) {
        otherContract = _otherContract;
    }

    event Response(string);

    function setColor(bytes3 _color) public {
        color = _color;
    }

    function callSetColor(bytes3 _color) external {
        bytes memory data = abi.encodeWithSelector(
            this.setColor.selector,
            _color
        );
        (bool success, ) = address(this).call(data);
        require(success, 'call failed');
    }

    function restricted(bytes3 _color) external {
        setColor(_color);
    }

    function callFunction(bytes calldata data) public {
        (bytes4 _sig, bytes3 _color) = abi.decode(data, (bytes4, bytes3));
        (bool success, ) = address(this).call(
            abi.encodeWithSelector(_sig, _color)
        );
        require(success, 'call failed');
    }

    function callReceive() external payable {
        (bool success, ) = otherContract.call{value: msg.value}('');
        require(success, "couldn't send funds");
        // transfer --> max 2300 gas
    }

    function callSetName(string calldata _name) public {
        bytes memory data = abi.encodeWithSignature('setName(string)', _name);
        (bool success, bytes memory response) = otherContract.call(data);
        require(success, "can't set name");
        emit Response(abi.decode(response, (string)));
    }
}

contract AnotherContract {
    string public name;
    mapping(address => uint256) public balances;

    function setName(string calldata _name) external returns (string memory) {
        name = _name;
        return name;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
    }
}
