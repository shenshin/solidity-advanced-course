//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract DelegateCaller {
  address callee;

  constructor(address _callee) {
    callee = _callee;
  }

  function delegeteCallGetData() external payable {
    (bool success, ) = callee.delegatecall(
      abi.encodeWithSelector(DelegateCallee.getData.selector)
    );
    require(success, "delegate call failed");
  }
}

contract DelegateCallee {
  event Received(address sender, uint value);
  function getData() external payable {
    emit Received(msg.sender, msg.value);
  }
}