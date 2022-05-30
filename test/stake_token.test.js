const truffleAssert = require("truffle-assertions");
const timeMachine = require("ganache-time-traveler");
const { assert } = require("chai");
const BN = require("bn.js");
require("chai").use(require("chai-as-promised")).should();

// const ContractFactory = artifacts.require("./ContractFactory");
const RealEstateToken = artifacts.require("./RealEstateToken.sol");
const USDC = artifacts.require("./Usdc.sol");
const TokenSale = artifacts.require("./TokenSale.sol");
const StakingContract = artifacts.require("./StakingContract.sol");
const StakeTokenNFT = artifacts.require("./StakeTokenNFT.sol");

contract("Staking Contract",async(accounts)=>{
    let token;
    let sale;
    let saleAddress;
    let stake;
    let stakeAddress;
    let stakeNft;
    let stakeNftAddress;
    let usdc;
    let bloq;

    before(async()=>{
        usdc = await USDC.new();
        bloq = await USDC.new();
        token = await RealEstateToken.new(
          usdc.address,
          "TestToken",
          "TT",
          90,
          1,
          1652848590,
          1753848590,
          "TestNft",
          "TN",
          accounts[1]
        );
        saleAddress = await token.saleAddress();
        sale = await TokenSale.at(saleAddress);
        stake = await StakingContract.new(accounts[1],token.address,usdc.address,bloq.address,5,5,"Stake NFT","SN");
        stakeNftAddress = await stake.nftAddress();
        stakeNft = await StakeTokenNFT.at(stakeNftAddress);
        usdc.transfer(stake.address,100000);
        bloq.transfer(stake.address,100000);
    })

    describe("Basic Info",async()=>{

      it("should check if staking contract of correct token is instantiated",async()=>{
        let address = await stake.getTokenAddress();
        assert.equal(address,token.address);
      })

      it("should check nft contract address",async()=>{
        let nftAddress = await stake.nftAddress();
        assert.equal(nftAddress,stakeNft.address);
      })

      it("should check the rewardPerToken",async()=>{
        let rewardUSDC = await stake.getRewardPerToken("USDC");
        let rewardBLOQ = await stake.getRewardPerToken("BLOQ");
        assert.equal(rewardUSDC,5);
        assert.equal(rewardBLOQ,5);
      })

      it("should check if the rewardPerToken can be updated",async()=>{
        await truffleAssert.passes(stake.setRewardPerToken(10,"BLOQ"));
        let rewardBLOQ = await stake.getRewardPerToken("BLOQ");
        assert.equal(rewardBLOQ,10);
      })
    })

    describe("Stake function",async()=>{

        it("should check if the customer has enough token to stake",async()=>{
          await truffleAssert.reverts(stake.stake(10000),"Not enough token to stake");
        })

        it("should stake token and mint nft",async()=>{
          await timeMachine.advanceBlockAndSetTime(1661823937);

          await usdc.approve(saleAddress, 2, { from: accounts[0] });
          await sale.purchase(2, { from: accounts[0] });
          await timeMachine.advanceBlockAndSetTime(1852848590);
          await truffleAssert.passes(sale.claim({ from: accounts[0] }));

          await token.approve(stake.address,"2",{from:accounts[0]});
          let tokenBalanceBeforeStake = await token.balanceOf(accounts[0]);
          await truffleAssert.passes(stake.stake("2"));
          let tokenBalanceAfterStake = await token.balanceOf(accounts[0]);
          assert.equal(tokenBalanceBeforeStake.sub(new BN("2",10)).toString(),tokenBalanceAfterStake.toString());

          let tokenBalance = await token.balanceOf(accounts[0]);
          assert.equal(tokenBalance,0);
          let balance = await stake.balanceOf(accounts[0],1);
          assert.equal(balance,2);
          let totalStake = await stake.totalStaked();
          assert.equal(totalStake ,2)
          let nftid = await stake.getNftId(accounts[0],1);
          let ownerOfNft = await stakeNft.ownerOf(nftid);
          assert.equal(ownerOfNft,accounts[0]);
        })
    })

    describe("Get Reward function",async()=>{

      it("should revert for wrong deposit id",async()=>{
        await truffleAssert.reverts(stake.getReward(10,"USDC"),"Wrong deposit id");
      })

      it("should return reward of specified token",async()=>{        
        await timeMachine.advanceBlockAndSetTime(1852858590);
        let a = await stake.getDepositDate(accounts[0],1);
        let expectedReward = 2+(2*0.05*(1852858590-a));
        let calcReward = await stake.calcReward(1,"USDC");
        assert.equal(Math.floor(expectedReward),calcReward)
        let balanceBeforeReward = await usdc.balanceOf(accounts[0]);
        await stake.getReward(1,"USDC");
        let balanceAfterReward = await usdc.balanceOf(accounts[0]);
        assert.equal(balanceBeforeReward.add(calcReward).toString(),balanceAfterReward.toString());
      })
    })

    describe("Withdraw function",async()=>{
      it("should revert for wrong deposit id",async()=>{
        await truffleAssert.reverts(stake.withdraw(10000,10,"USDC"),"Wrong deposit id");
      })

      it("should revert for insufficient fund in stake",async()=>{
        await truffleAssert.reverts(stake.withdraw(10000,1,"USDC"),"Insufficent funds");
      })
      
      it("should withdraw portion of the staked token and issue new nft",async()=>{
        let totalStakeBeforeWithdraw = await stake.totalStaked();
        let stakedAmountBeforeWithdraw = await stake.balanceOf(accounts[0],1);
        let tokenBalanceBeforeWithdraw = await token.balanceOf(accounts[0]);
        await timeMachine.advanceBlockAndSetTime(1852859590);
        await truffleAssert.passes(stake.withdraw(1,1,"USDC"));
        let totalStakeAfterWithdraw = await stake.totalStaked();
        let stakedAmountAfterWithdraw = await stake.balanceOf(accounts[0],1);        
        let tokenBalanceAfterWithdraw = await token.balanceOf(accounts[0]);
        let ownerOfNewNft = await stakeNft.ownerOf(1);
        assert.equal(ownerOfNewNft,accounts[0]);
        assert.equal(totalStakeBeforeWithdraw.sub(new BN(1,10)).toString(),totalStakeAfterWithdraw);
        assert.equal(stakedAmountBeforeWithdraw.sub(new BN(1,10)).toString(),stakedAmountAfterWithdraw);
        assert.equal(tokenBalanceBeforeWithdraw.add(new BN(1,10)).toString(),tokenBalanceAfterWithdraw);
      })

      it("should withdraw all of the staked token",async()=>{
        let totalStakeBeforeWithdraw = await stake.totalStaked();
        let stakedAmountBeforeWithdraw = await stake.balanceOf(accounts[0],1);
        let tokenBalanceBeforeWithdraw = await token.balanceOf(accounts[0]);
        await timeMachine.advanceBlockAndSetTime(1852859690);
        await truffleAssert.passes(stake.withdraw(1,1,"USDC"));
        let totalStakeAfterWithdraw = await stake.totalStaked();
        let stakedAmountAfterWithdraw = await stake.balanceOf(accounts[0],1);        
        let tokenBalanceAfterWithdraw = await token.balanceOf(accounts[0]);
        await truffleAssert.reverts(stakeNft.ownerOf(2),"ERC721: owner query for nonexistent token");
        assert.equal(totalStakeBeforeWithdraw.sub(new BN(1,10)).toString(),totalStakeAfterWithdraw);
        assert.equal(stakedAmountBeforeWithdraw.sub(new BN(1,10)).toString(),stakedAmountAfterWithdraw);
        assert.equal(tokenBalanceBeforeWithdraw.add(new BN(1,10)).toString(),tokenBalanceAfterWithdraw);
      })

    })
})