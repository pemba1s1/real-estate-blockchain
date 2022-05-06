// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ERC20Interface.sol";

contract RealEstateToken is ERC20Interface , Ownable {

  mapping(address => uint256) _balances;
  mapping(address =>mapping(address=>uint256)) _allowances;

  string private _tokenName;
  string private _tokenSymbol;
  uint8 private _decimals;
  uint256 private _totalSupply;
  uint256 private _initialPrice;
  uint256 private _saleStart;
  uint256 private _saleEnd;
  string private _nftName;
  string private _nftSymbol;

  constructor(string memory tokenName_,string memory tokenSymbol_,uint256 totalSupply_,uint256 initialPrice_,uint256 saleStart_,uint256 saleEnd_,string memory nftName_,string memory nftSymbol_,address _owner) {
    owner = _owner;
    _tokenName = tokenName_;
    _decimals = 18;
    _tokenSymbol = tokenSymbol_;
    _totalSupply = totalSupply_ * 10**_decimals;
    _initialPrice = initialPrice_;
    _saleStart = saleStart_;
    _saleEnd = saleEnd_;
    _nftName = nftName_;
    _nftSymbol = nftSymbol_;
    _balances[owner] = _totalSupply;
  }

  function totalSupply() public view virtual override returns (uint256){
    return _totalSupply;
  }
  
  function getOwner() public view returns(address){
      return owner;
  }

  function name() public view virtual override returns (string memory){
    return _tokenName;
  }

  function decimals() public view virtual override returns (uint8){
    return _decimals;
  }

  function symbol() public view virtual override returns (string memory){
    return _tokenSymbol;
  }

  function nftName() public view virtual returns(string memory){
    return _nftName;
  }

  function nftSymbol() public view virtual returns(string memory){
    return _nftSymbol;
  }

  function initialPrice() public view virtual returns (uint256) {
      return _initialPrice;
  }

  function saleStart() public view virtual returns (uint256) {
      return _saleStart;
  }

  function saleEnd() public view virtual returns (uint256) {
      return _saleEnd;
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
        _transfer(msg.sender, _to, _amount);
        return true;
      }

  function approve(address _spender, uint256 _amount)
      public
      virtual
      override
      returns (bool success){
        _approve(msg.sender, _spender, _amount* 10**_decimals);
        return true;
      }

  function transferFrom(
      address _from,
      address _to,
      uint256 _amount
  ) public virtual override returns (bool success){
    _spendAllowance(_from, msg.sender, _amount);
    _transfer(_from, _to, _amount);
    return true;
  }

  function increaseAllowance(address _spender,uint256 _amount) public virtual returns(bool){
    _approve(msg.sender, _spender, allowance(msg.sender,_spender)+_amount * 10**_decimals);
    return true;
  }

  function decreaseAllowance(address _spender,uint256 _amount) public virtual returns(bool){
    require(allowance(msg.sender, _spender)>=_amount* 10**_decimals,"Allowance cannot be less than zero");
    _approve(msg.sender, _spender, allowance(msg.sender,_spender)-_amount * 10**_decimals);
    return true;
  }

  function purchase(uint256 _amount,uint256 _time) public virtual returns(bool){
        require(_amount* 10**_decimals<=_balances[owner],"Total supply exceeded");
        require(_time>_saleStart,"Sale hasn't started yet");
        require(_time<_saleEnd,"Sale has ended");
        _transfer(owner, msg.sender, _amount);
        return true;
    }

    // function withdraw(uint _amount) public onlyOwner{
    //     require(block.timestamp<_saleEnd,"Sale hasn't ended");

    // }
    function issue() public onlyOwner{

    }
    function Return() public {

    }
    function updateSaleStartTime(uint256 updatedSaleStartTime) public onlyOwner{
        _saleStart = updatedSaleStartTime;
    }
    function updateSaleEndTime(uint256 updatedSaleEndTime) public onlyOwner{
        _saleEnd = updatedSaleEndTime;
    }

  function _transfer(address _from,address _to,uint256 _amount) internal virtual{
    require(_from != address(0),"transfer from the zero address");
    require(_to != address(0),"transfer to the zero address");
    require(_balances[_from]>=_amount* 10**_decimals,"Amount exceeds balance");

    unchecked {
      _balances[_from] -= _amount* 10**_decimals;
    }
    _balances[_to] += _amount* 10**_decimals;

    emit Transfer(_from, _to, _amount* 10**_decimals);

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
    require(_allowances[_owner][_spender]>=_amount* 10**_decimals,"not enough token allowed");
    unchecked {
      _allowances[_owner][_spender] -= _amount* 10**_decimals;      
    }
  }


}
