//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";

contract ERC20 is IERC20, Ownable {
  mapping(address => uint) private balances;
  mapping(address => mapping(address => uint)) private allowances;
  string private _symbol;
  string private _name;
  uint private _totalSupply;

  constructor(string memory name_, string memory symbol_, uint initialSupply, address shop) {
    _name = name_;
    _symbol = symbol_;
    mint(initialSupply, shop);
  }

  modifier enoughTokens(address _from, uint _amount) {
    require(balanceOf(_from) >= _amount, "insuffiecient token balance");
    _;
  }

  function mint(uint amount, address _owner) public onlyOwner {
    _transfer(address(0), _owner, amount);
    _totalSupply += amount;
  }

  function name() public view override(IERC20) returns(string memory) {
    return _name;
  }

  function symbol() public view override(IERC20) returns(string memory) {
    return _symbol;
  }

  function balanceOf(address account) public view override(IERC20) returns(uint) {
    return balances[account];
  }
  function totalSupply() external view override(IERC20) returns(uint) {
    return _totalSupply;
  }

  function decimals() override(IERC20) external pure returns(uint) {
    return 18;
  }

  function transfer(address to, uint amount) external enoughTokens(msg.sender, amount) override(IERC20) {
    _transfer(msg.sender, to, amount);
  }

  function allowance(address _owner, address _spender) public view override(IERC20) returns(uint) {
    return allowances[_owner][_spender];
  }

  function approve(address spender, uint amount) public override(IERC20) {
    _approve(msg.sender, spender, amount);
  }

  function transferFrom(address sender, address recipient, uint amount) external enoughTokens(sender, amount) override(IERC20) {
    require(allowance(sender, recipient) >= amount, "insufficient allowance");
    allowances[sender][recipient] -= amount;
    _transfer(sender, recipient, amount);
  }

  function burn(uint amount) public onlyOwner enoughTokens(msg.sender, amount) {
    _transfer(msg.sender, address(0), amount);
    _totalSupply -= amount;
  }

  function _approve(address sender, address spender, uint amount) internal virtual {
    allowances[sender][spender] = amount;
    emit Approve(sender, spender, amount);
  }

  function _transfer(address from, address to, uint amount) internal virtual {
    _beforeTokenTransfer(from, to, amount);
    // not to track zero address
    if (from != address(0)) {
      balances[from] -= amount;
    }
    if (to != address(0)) {
      balances[to] += amount;
    }
    emit Transfer(from, to, amount);
  }

  function _beforeTokenTransfer(address from, address to, uint amount) internal virtual {}
}