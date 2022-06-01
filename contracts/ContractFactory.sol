// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "./RealEstateToken.sol";
import "./StakingContract.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract ContractFactory is Ownable{
    RealEstateToken private token;
    StakingContract private stake;
    address private _implementationAddressToken;
    address private _implementationAddressStake;
    

    event PropertyDeployed(address indexed propertyAddress,string _tokenName,string _tokenSymbol);
    event StakeContractDeployed(address indexed stakeAddress,address indexed propertyAddress,string _nftName);

    mapping(string => address) propertyTokenAddress;
    mapping(address => bool) deployed;
    mapping(address => address) stakeAddress;

    constructor(address implementationAddressToken_,address implementationAddressStake_){
        _implementationAddressToken=implementationAddressToken_;
        _implementationAddressStake=implementationAddressStake_;
    }

    function getOwner() public view returns(address){
        return owner();
    }

    function getTokenAddress(string memory tokenName_) public view returns(address){
        return propertyTokenAddress[tokenName_];
    }

    function getStakeAddress(address tokenAddress_) public view returns(address){
        return stakeAddress[tokenAddress_];
    }

    function setTokenCloneAddress(address implementationAddressToken_) public{
        _implementationAddressToken=implementationAddressToken_;
    }

    function setStakeCloneAddress(address implementationAddressStake_) public{
        _implementationAddressStake=implementationAddressStake_;
    }

    function deployProperty(address implementationAddressSale,address usdc,string memory _tokenName,string memory _tokenSymbol,uint256 _totalSupply,uint256 _tokenInitialPrice,uint256 _saleStart,uint256 _saleEnd,address _owner) public virtual returns(bool){
        token = RealEstateToken(Clones.clone(_implementationAddressToken));
        token.setSaleCloneAddress(implementationAddressSale);
        token.initialize(usdc,_tokenName,_tokenSymbol,_totalSupply,_tokenInitialPrice,_saleStart,_saleEnd,_owner);
        propertyTokenAddress[_tokenName] = address(token);
        emit PropertyDeployed(address(token),_tokenName, _tokenSymbol);
        return true;
    }

    function delpoyStakeContract(address implementationAddressNFT, address owner_, address tokenAddress_,address usdc_,address bloq_,uint256 rewardPerTokenUSDC_,uint256 rewardPerTokenBLOQ_,string memory nftName_,string memory nftSymbol_ ) public virtual returns(bool){
        require(deployed[tokenAddress_] != true,"Stake contract already deployed");
        stake = StakingContract(Clones.clone(_implementationAddressStake));
        stake.setNFTCloneAddress(implementationAddressNFT);
        stake.initialize(owner_, tokenAddress_,usdc_,bloq_,rewardPerTokenUSDC_,rewardPerTokenBLOQ_, nftName_,nftSymbol_);
        deployed[tokenAddress_] = true;
        stakeAddress[tokenAddress_] = address(stake);
        emit StakeContractDeployed(address(stake), tokenAddress_, nftName_);
        return true;
    }


}