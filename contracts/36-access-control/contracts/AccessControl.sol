// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './IAccessControl.sol';

abstract contract AccessControl is IAccessControl {
    struct RoleData {
      // tells if address belongs to this role
        mapping(address => bool) members;
        // superior role
        bytes32 adminRole;
        // uint count;
    }

    // set of roles
    mapping(bytes32 => RoleData) private _roles;

    // initially there's only one default Super-Admin role
    // who can revoke himself
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    // only this role can do smth
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function hasRole(
        bytes32 role,
        address account
    ) public view virtual returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(
        bytes32 role,
        address account
    ) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(
        bytes32 role,
        address account
    ) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == msg.sender, 'can only renounce for self');
        // if role == DEFAULT_ADMIN_ROLE && count < 2...
        _revokeRole(role, account);
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, msg.sender);
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert('no such role!');
        }
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 prevAdminRole = getRoleAdmin(role);

        _roles[role].adminRole = adminRole;

        emit RoleAdminChanged(role, prevAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }
}
