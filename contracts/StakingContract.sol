// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./StakeTokenNFT.sol";
import "./RealEstateTokenInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingContract is Ownable , ReentrancyGuard{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    StakeTokenNFT nft;
    address private _tokenAddress;

    mapping(string => address) rewardTokenAddress;
    mapping(string => uint256) rewardPerToken;
    mapping(address => mapping(uint256=>uint256)) balances;
    mapping(address => mapping(uint256=>uint256)) nftId;
    mapping(address => mapping(uint256=>uint256)) depositDates;
    mapping(address => uint256) lastDepositIds;

    uint256 private _totalStaked;

    event Deposited(address indexed sender, uint256 amount, uint256 id ,string depositTokenType);
    event Withdrawn(address indexed sender, uint256 amount, uint256 id);
    event RewardSet(uint256 rewardPerToken, address sender);
    event RewardWithdrawn(address indexed sender, uint256 reward,string rewardTokenType);

    constructor(address owner_, address tokenAddress_,address usdc_,address bloq_,uint256 rewardPerTokenUSDC_,uint256 rewardPerTokenBLOQ_,string memory nftName_,string memory nftSymbol_ ){
        transferOwnership(owner_);
        _tokenAddress = tokenAddress_;
        rewardTokenAddress["USDC"] = usdc_;
        rewardTokenAddress["BLOQ"] = bloq_;
        rewardPerToken["USDC"] = rewardPerTokenUSDC_;
        rewardPerToken["BLOQ"] = rewardPerTokenBLOQ_;
        nft = new StakeTokenNFT(nftName_,nftSymbol_);
        _totalStaked = 0;
    }

    function nftAddress() public view returns(address){
        return address(nft);
    }

    function getTokenAddress() public view returns(address){
        return _tokenAddress;
    }

    function totalStaked() public view returns(uint256){
        return _totalStaked;
    }

    function getRewardPerToken(string memory token) public view returns(uint256){
        return rewardPerToken[token];
    }

    function setRewardPerToken(uint256 newRewardPerToken,string memory token) public returns(bool){
        rewardPerToken[token] = newRewardPerToken;
        emit RewardSet(rewardPerToken[token], msg.sender);
        return true;
    }

    function balanceOf(address addres,uint256 id) public view returns(uint256){
        return balances[addres][id];
    }

    function getDepositDate(address addres,uint256 id) public view returns(uint256){
        return depositDates[addres][id];
    }

    function getNftId(address addres,uint256 id) public view returns(uint256){
        return nftId[addres][id];
    }

    function stake(uint256 _amount) public returns(bool){        
        _stake(_amount, _tokenAddress, msg.sender,++ lastDepositIds[msg.sender]);
        return true;
    }

    function stake(uint256 _amount,address _lpTokenAddres) public returns(bool){
        _stake(_amount, _lpTokenAddres, msg.sender,++ lastDepositIds[msg.sender]);
        return true;
    }

    function withdraw(uint256 _amount,uint256 id,string memory rewardToken) public returns(bool) {
        _withdraw(_amount,_tokenAddress,msg.sender,id,rewardToken);
        return true;
    }  

    function getReward(uint256 id,string memory rewardToken) public returns(bool){
        require(id>0 && id<=lastDepositIds[msg.sender],"Wrong deposit id");
        uint256 amount = balances[msg.sender][id];
        uint256 depositDate = depositDates[msg.sender][id];
        depositDates[msg.sender][id] = block.timestamp;
        _getReward(msg.sender,amount,depositDate,rewardToken);
        return true;
    }

    function calcReward(uint256 id,string memory rewardToken) public view returns(uint256){
        require(id>0 && id<=lastDepositIds[msg.sender],"Wrong deposit id");
        uint256 amount = balances[msg.sender][id];
        uint256 depositDate = depositDates[msg.sender][id];
        if(amount != 0 && block.timestamp >= depositDate){
            uint256 timePassed = block.timestamp.sub(depositDate);
            uint256 reward = amount.add(amount.mul(timePassed).mul(rewardPerToken[rewardToken]).div(100));
            return reward;
        }else{
            return 0;
        }
    }

    function earned() public {

    }

    function _withdraw(uint256 amount, address tokenAddress,address sender, uint256 id,string memory rewardToken) internal{
        require(id>0 && id<=lastDepositIds[sender],"Wrong deposit id");
        require(balances[sender][id]>=amount,"Insufficent funds");
        balances[sender][id] = balances[sender][id].sub(amount);
        _totalStaked = _totalStaked.sub(amount);
        _burn(nftId[sender][id]);
        _getReward(sender,amount,depositDates[sender][id],rewardToken);
        if(balances[sender][id]==0){
            depositDates[sender][id] = 0;
            delete nftId[sender][id];
        }else{
            depositDates[sender][id] = block.timestamp;
            uint256 tokenId = _issue(sender);
            nftId[sender][id] = tokenId;
        }
        IERC20(tokenAddress).safeTransfer(sender,amount);
        emit Withdrawn(sender,amount,id);
    }

    function _getReward(address sender,uint256 amount, uint256 depositDate,string memory rewardToken) internal returns(uint256){
        if(amount != 0 && block.timestamp >= depositDate){
            uint256 timePassed = block.timestamp.sub(depositDate);        
            uint256 reward = amount.add(amount.mul(timePassed).mul(rewardPerToken[rewardToken]).div(100));
            IERC20(rewardTokenAddress[rewardToken]).safeTransfer(sender,reward);
            emit RewardWithdrawn(sender,reward,rewardToken);
            return reward;
        }else{            
            emit RewardWithdrawn(sender,0,rewardToken);
            return 0;
        }
    }

    function _stake(uint256 amount, address tokenAddress,address to,uint256 _depositId) internal{
        require(_depositId > 0 && _depositId <= lastDepositIds[msg.sender], "wrong deposit id");
        require(IERC20(tokenAddress).balanceOf(to)>=amount,"Not enough token to stake");
        balances[msg.sender][_depositId] = amount;
        _totalStaked = _totalStaked.add(amount);
        depositDates[msg.sender][_depositId] = block.timestamp;
        IERC20(tokenAddress).safeTransferFrom(to,address(this),amount);
        uint256 tokenId = _issue(to);
        nftId[msg.sender][_depositId] = tokenId;
    }  

    function _issue(address to_) internal returns(uint256){
        return nft.mint(to_);
    }

    function _burn(uint256 tokenId_) internal{
        nft.burn(tokenId_);
    }
    
}