// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDC is IERC20 , Ownable  {

  mapping(address => uint256) _balances;
  mapping(address =>mapping(address=>uint256)) _allowances;

  string private _tokenName="TEST";
  string private _tokenSymbol="TT";
  uint8 private _decimals=18;
  uint256 private _totalSupply=10000000000000000000000;

  constructor(){
      _balances[owner()]= _totalSupply;
  }


  function totalSupply() public view virtual override returns (uint256){
    return _totalSupply;
  }
  
  function getOwner() public view returns(address){
      return owner();
  }

  function name() public view virtual returns (string memory){
    return _tokenName;
  }

  function decimals() public view virtual returns (uint8){
    return _decimals;
  }

  function symbol() public view virtual returns (string memory){
    return _tokenSymbol;
  }

  function balanceOf(address tokenOwner)
      public
      view
      virtual
      override
      returns (uint256 balance){
        return _balances[tokenOwner];
      }


  function allowance(address tokenOwner, address spender)
      public
      view
      virtual
      override
      returns (uint256 remaining){
        return _allowances[tokenOwner][spender];
      }

  function transfer(address _to, uint256 _amount)
      public
      virtual
      override
      returns (bool success){        
      require(_balances[msg.sender]>=_amount,"Amount exceeds balance");
        _transfer(msg.sender, _to, _amount);
        return true;
      }

  function approve(address _spender, uint256 _amount)
      public
      virtual
      override
      returns (bool){
        _approve(msg.sender, _spender, _amount);
        return true;
      }

  function transferFrom(
      address _from,
      address _to,
      uint256 _amount
  ) public virtual override returns (bool success){
    
    require(_balances[_from]>=_amount,"Amount exceeds balance");
    // uint adsd = _amount*10**_decimals;
    _spendAllowance(_from, msg.sender, _amount);
    _transfer(_from, _to, _amount );
    return true;
  }

  function increaseAllowance(address _spender,uint256 _amount) public virtual returns(bool){
    _approve(msg.sender, _spender, allowance(msg.sender,_spender)+_amount);
    return true;
  }

  function decreaseAllowance(address _spender,uint256 _amount) public virtual returns(bool){
    require(allowance(msg.sender, _spender)>=_amount,"Allowance cannot be less than zero");
    _approve(msg.sender, _spender, allowance(msg.sender,_spender)-_amount);
    return true;
  }

  function _transfer(address _from,address _to,uint256 _amount) internal virtual{
    require(_from != address(0),"transfer from the zero address");
    require(_to != address(0),"transfer to the zero address");

    _balances[_from] -= _amount;
    _balances[_to] += _amount;

    emit Transfer(_from, _to, _amount);

  }
  function _approve(address _owner,address _spender,uint256 _amount) internal virtual{
    require(_owner != address(0),"cannot approve from address 0");
    require(_spender != address(0),"cannot approve to address 0");
    require(_balances[_owner]>=_amount,"not enough token");

    _allowances[_owner][_spender] = _amount;

    emit Approval(_owner, _spender, _amount);
  }

  function _spendAllowance(address _owner,address _spender,uint256 _amount) internal virtual{
    require(_owner != address(0),"cannot spend allownace from address 0");
    require(_spender != address(0),"cannot spend allownace to address 0");
    require(allowance(_owner,_spender)>=_amount,"not enough token allowed");
    unchecked {
      _allowances[_owner][_spender] -= _amount;      
    }
  }


}
