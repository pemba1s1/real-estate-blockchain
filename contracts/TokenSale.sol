//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./RealEstateTokenInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TokenSale is Ownable{
  using SafeERC20 for IERC20;
  address private _tokenAddress;
  uint256 private _saleStart;
  uint256 private _saleEnd;
  address public _usdcInstance;
  
  mapping(address => uint256) record;

  constructor(address _owner,address tokenAddress_,uint256 saleStart_,uint256 saleEnd_,address usdcAddress_){
    _transferOwnership(_owner);
    _usdcInstance = usdcAddress_;
    _tokenAddress = tokenAddress_;
    _saleStart = saleStart_;
    _saleEnd = saleEnd_;
  }  

  function saleStart() public view virtual returns (uint256) {
      return _saleStart;
  }

  function tokenAddress() public view returns(address){
    return _tokenAddress;
  }

  function getOwner() public view returns(address){
      return owner();
  }

  function bala(address add) public view virtual returns (uint256){
    return IERC20(_usdcInstance).balanceOf(add);
  }

  function allowance(address owner,address spender) public view returns (uint256){
    return IERC20(_usdcInstance).allowance(owner, spender);
  }

  function saleEnd() public view virtual returns (uint256) {
      return _saleEnd;
  }

  function getRecord(address _address) public virtual view returns(uint256){
    return record[_address];
  }

  function purchase(uint256 _amount) public{
      require(block.timestamp>=_saleStart,"Sale hasn't started yet");
      require(block.timestamp<=_saleEnd,"Sale has ended");
      IERC20(_usdcInstance).safeTransferFrom(msg.sender,address(this), _amount);
      record[msg.sender] += _amount;
  }

  function withdraw(address _to) public virtual onlyOwner{
      require(block.timestamp>_saleEnd,"Sale hasn't ended");
      uint256 amt = IERC20(_usdcInstance).balanceOf(address(this));
      IERC20(_usdcInstance).safeTransfer(_to,amt);
  }

  function claim() public virtual{
    require(block.timestamp>=_saleEnd,"Sale hasn't ended");
    RealEstateTokenInterface(_tokenAddress).mint(msg.sender,record[msg.sender]);
    delete record[msg.sender];
  }

  function Return(uint256 _amount) public returns(bool){
    require(IERC20(_usdcInstance).balanceOf(address(this))>=_amount,"Not enough token to return");
    require(record[msg.sender]>=_amount,"You dont have enought token to return");
    // _tokenAddress._balances[owner] += returnAmt;
    IERC20(_usdcInstance).safeTransfer(msg.sender,_amount);
    record[msg.sender] -= _amount;
    return true;
  }

  function updateSaleStartTime(uint256 updatedSaleStartTime) public onlyOwner{
      _saleStart = updatedSaleStartTime;
  }
  function updateSaleEndTime(uint256 updatedSaleEndTime) public onlyOwner{
      _saleEnd = updatedSaleEndTime;
  }

}