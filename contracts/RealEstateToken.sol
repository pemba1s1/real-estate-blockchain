// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenSale.sol";
import "./RealEstateTokenInterface.sol";

contract RealEstateToken is RealEstateTokenInterface , Ownable  {

  mapping(address => uint256) _balances;
  mapping(address =>mapping(address=>uint256)) _allowances;

  string private _tokenName;
  string private _tokenSymbol;
  uint8 private _decimals;
  uint256 private _maxSupply;
  uint256 private _totalSupply;
  uint256 private _initialPrice;
  string private _nftName;
  string private _nftSymbol;
  address private _saleAddress;

  event Received(address, uint);

  constructor(address usdc,string memory tokenName_,string memory tokenSymbol_,uint256 maxSupply_,uint256 initialPrice_,uint256 saleStart_,uint256 saleEnd_,string memory nftName_,string memory nftSymbol_,address _owner) {
    _transferOwnership(_owner);
    _tokenName = tokenName_;
    _decimals = 18;
    _tokenSymbol = tokenSymbol_;
    _maxSupply = maxSupply_ * 10**_decimals;
    _initialPrice = initialPrice_;
    _nftName = nftName_;
    _nftSymbol = nftSymbol_;
    _totalSupply = 0;
    TokenSale ts = new TokenSale(_owner,address(this),saleStart_,saleEnd_,usdc);
    _saleAddress = address(ts);
  }


  function totalSupply() public view virtual override returns (uint256){
    return _totalSupply;
  }

  function maxSupply() public view returns (uint256){
    return _maxSupply;
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

  function nftName() public view virtual returns(string memory){
    return _nftName;
  }

  function nftSymbol() public view virtual returns(string memory){
    return _nftSymbol;
  }

  function initialPrice() public view virtual returns (uint256) {
      return _initialPrice;
  }

  function saleAddress() public view virtual returns(address){
    return _saleAddress;
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
      returns (bool success){
        _approve(msg.sender, _spender, _amount);
        return true;
      }

  function transferFrom(
      address _from,
      address _to,
      uint256 _amount
  ) public virtual override returns (bool success){
    
    require(_balances[_from]>=_amount,"Amount exceeds balance");
    _spendAllowance(_from, msg.sender, _amount);
    _transfer(_from, _to, _amount);
    return true;
  }  

  function mint(address _address,uint256 _amount) public virtual override returns(bool){
    require(_address != address(0),"Cannot mint to address 0");
    require(_maxSupply>=_totalSupply+_amount,"Max supply exceeded");

    _totalSupply += _amount;
    _balances[_address] += _amount;

    emit Transfer(address(0),_address,_amount);

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
    require(_allowances[_owner][_spender]>=_amount,"not enough token allowed");
    unchecked {
      _allowances[_owner][_spender] -= _amount;      
    }
  }

}
