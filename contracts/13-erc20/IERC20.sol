//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external pure returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external;

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approve(address indexed owner, address indexed to, uint256 amount);
    // error MyError(param1, param2);
}
