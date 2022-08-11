// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Proxy {
    address public implementation;
    uint256 public x;

    function setImplementation(address _imp) external {
        implementation = _imp;
    }

    function _delegate(address _imp) internal virtual returns (bytes memory) {
        /* assembly {
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), _imp, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    } */
        (bool success, bytes memory result) = _imp.delegatecall(msg.data);
        require(success, 'implementation call failed');
        return result;
    }

    fallback() external payable {
        _delegate(implementation);
    }

    receive() external payable {}
}

contract V1 {
    address public impementation;
    uint256 public x;

    function inc() external {
        x += 1;
    }
}

contract V2 {
    address public impementation;
    uint256 public x;

    function inc() external {
        x += 1;
    }

    function dec() external {
        x -= 1;
    }
}
