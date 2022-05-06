// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "./RealEstateToken.sol";
import "./Ownable.sol";

contract ContractFactory is Ownable{
    RealEstateToken public token;

    event PropertyDeployed(string _tokenName,string _tokenSymbol);

    function getOwner() public view returns(address){
        return owner;
    }

    function deployProperty(string memory _tokenName,string memory _tokenSymbol,uint256 _totalSupply,uint256 _tokenInitialPrice,uint256 _saleStart,uint256 _saleEnd,string memory _nftName,string memory _nftSymbol,address _owner) public virtual returns(bool){
        token = new RealEstateToken(_tokenName,_tokenSymbol,_totalSupply,_tokenInitialPrice,_saleStart,_saleEnd,_nftName,_nftSymbol,_owner);
        emit PropertyDeployed(_tokenName, _tokenSymbol);
        return true;
    }


}