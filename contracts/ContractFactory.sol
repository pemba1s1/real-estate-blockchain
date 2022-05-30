// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "./RealEstateToken.sol";
// import "./StakingContract.sol";

contract ContractFactory is Ownable{
    RealEstateToken public token;
    // StakingContract public stake;
    

    event PropertyDeployed(address indexed propertyAddress,string _tokenName,string _tokenSymbol);
    event StakeContractDeployed(address indexed stakeAddress,address indexed propertyAddress,string _nftName);

    address[] public propertyTokenAddress;
    mapping(address => bool) deployed;

    function getOwner() public view returns(address){
        return owner();
    }

    function deployProperty(address usdc,string memory _tokenName,string memory _tokenSymbol,uint256 _totalSupply,uint256 _tokenInitialPrice,uint256 _saleStart,uint256 _saleEnd,string memory _nftName,string memory _nftSymbol,address _owner) public virtual returns(bool){
        token = new RealEstateToken(usdc,_tokenName,_tokenSymbol,_totalSupply,_tokenInitialPrice,_saleStart,_saleEnd,_nftName,_nftSymbol,_owner);
        propertyTokenAddress.push(address(token));
        emit PropertyDeployed(address(token),_tokenName, _tokenSymbol);
        return true;
    }

    // function delpoyStakeContract(address owner_, address tokenAddress_,address usdc_,address bloq_,uint256 rewardPerTokenUSDC_,uint256 rewardPerTokenBLOQ_,string memory nftName_,string memory nftSymbol_ ) public virtual returns(bool){
    //     require(deployed[tokenAddress_] != true,"Stake contract already deployed");
    //     stake = new StakingContract(owner_, tokenAddress_,usdc_,bloq_,rewardPerTokenUSDC_,rewardPerTokenBLOQ_, nftName_,nftSymbol_ );
    //     deployed[tokenAddress_] = true;
    //     emit StakeContractDeployed(address(stake), tokenAddress_, nftName_);
    //     return true;
    // }


}