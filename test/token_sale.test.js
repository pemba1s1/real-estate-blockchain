const truffleAssert = require("truffle-assertions");
const timeMachine = require("ganache-time-traveler");
const { assert } = require("chai");
const BN = require("bn.js");

const ContractFactory = artifacts.require("./ContractFactory");
const RealEstateToken = artifacts.require("./RealEstateToken");
const USDC = artifacts.require("./Usdc.sol");
const TokenSale = artifacts.require("./TokenSale.sol");

contract("Token Sale", function (accounts) {
  let contractFactory;
  let tokenAddress;
  let usdc;
  let token;
  let saleAddress;
  let sale;

  before(async () => {
    let a = await RealEstateToken.new();
    let b = await TokenSale.new();
    contractFactory = await ContractFactory.new(a.address,"0x1875c4Fa5EC8712eB388f8f40a099401dBF320DA");
    usdc = await USDC.new();
    await contractFactory.deployProperty(
      b.address,
      usdc.address,
      "TestToken",
      "TT",
      90,
      1,
      1652848590,
      1753848590,
      accounts[1]
    );
    tokenAddress = await contractFactory.getTokenAddress("TestToken");
    token = await RealEstateToken.at(tokenAddress);
    saleAddress = await token.saleAddress();
    sale = await TokenSale.at(saleAddress);
  });

  describe("Purchase functions", async () => {
    it("check if reverts without allowance", async () => {
      await timeMachine.advanceBlockAndSetTime(1652848590);
      await truffleAssert.reverts(
        sale.purchase(100, {
          from: accounts[0],
        }),
        "not enough token allowed"
      );
    });

    it("check if total supply is finished while purchasing", async () => {
      await timeMachine.advanceBlockAndSetTime(1652848590);
      await usdc.approve(saleAddress, 91, { from: accounts[0] });
      await truffleAssert.reverts(
        sale.purchase("150000000000000000000000000000", { from: accounts[0] }),
        "Amount exceeds balance"
      );
    });

    it("check if buyer can purchase token", async () => {
      await timeMachine.advanceBlockAndSetTime(1661823937);
      await usdc.approve(saleAddress, 20, { from: accounts[0] });
      await sale.purchase(20, { from: accounts[0] });
      let balance = await usdc.balanceOf(saleAddress);
      assert.equal(balance, 20);
    });

    it("check if token sale hasnt started", async () => {
      await timeMachine.advanceBlockAndSetTime(1552848590);
      await truffleAssert.reverts(
        sale.purchase(10, { from: accounts[0] }),
        "Sale hasn't started yet"
      );
    });

    it("check if token sale has ended", async () => {
      await timeMachine.advanceBlockAndSetTime(1852848590);
      await truffleAssert.reverts(
        sale.purchase(1, { from: accounts[0] }),
        "Sale has ended"
      );
    });
  });

  describe("Token sale time", async () => {
    it("check if saleStart is 1652848590", async function () {
      const saleStart = await sale.saleStart();
      assert.equal(saleStart, 1652848590);
    });

    it("check if saleEnd is 1753848590", async function () {
      const saleEnd = await sale.saleEnd();
      assert.equal(saleEnd, 1753848590);
    });
    it("should check that only owner can update sale start time", async () => {
      await truffleAssert.reverts(
        sale.updateSaleStartTime(1661823937, { from: accounts[0] }),
        "Ownable: caller is not the owner"
      );
    });

    it("should check that only owner can update sale end time", async () => {
      await truffleAssert.reverts(
        sale.updateSaleEndTime(1661823937, { from: accounts[0] }),
        "Ownable: caller is not the owner"
      );
    });

    it("should update sale start", async () => {
      await sale.updateSaleStartTime(1661823937, {
        from: accounts[1],
      });
      const newSaleStartTime = await sale.saleStart();
      assert.equal(newSaleStartTime, 1661823937);
    });

    it("should update sale end", async () => {
      await sale.updateSaleEndTime(1771823937, {
        from: accounts[1],
      });
      const newSaleStartTime = await sale.saleEnd();
      assert.equal(newSaleStartTime, 1771823937);
    });
  });

  describe("should check Return function", async () => {
    it("should check if smart contract has enough token to return", async () => {
      await timeMachine.advanceBlockAndSetTime(1852848590);
      await truffleAssert.reverts(
        sale.Return(100000000, { from: accounts[0] }),
        "Not enough token to return"
      );
    });

    it("should check if user has enough token to return", async () => {
      await timeMachine.advanceBlockAndSetTime(1852848590);
      await truffleAssert.reverts(
        sale.Return(1, { from: accounts[5] }),
        "You dont have enought token to return"
      );
    });

    it("should check if record decreases and the balance of user increases", async () => {
      let recordAmt = await sale.getRecord(accounts[0]);
      let balance = await usdc.balanceOf(accounts[0]);
      await truffleAssert.passes(sale.Return(10, { from: accounts[0] }));
      let recordAmtAfterReturn = await sale.getRecord(accounts[0]);
      let balanceAfterReturn = await usdc.balanceOf(accounts[0]);
      assert.equal(
        recordAmt.sub(new BN("10", 10)).toString(),
        recordAmtAfterReturn.toString()
      );
      assert.equal(
        balance.add(new BN("10", 10)).toString(),
        balanceAfterReturn.toString()
      );
    });
  });

  describe("should check claim function", async () => {
    it("should not allow user to claim their token before sale has ended", async () => {
      await timeMachine.advanceBlockAndSetTime(1552848590);
      await truffleAssert.reverts(
        sale.claim({ from: accounts[0] }),
        "Sale hasn't ended"
      );
    });

    it("should allow user to claim their token after sale has ended", async () => {
      await timeMachine.advanceBlockAndSetTime(1852848590);
      await truffleAssert.passes(sale.claim({ from: accounts[0] }));
      let balance = await token.balanceOf(accounts[0]);
      let remaining = await sale.getRecord(accounts[0]);
      assert.equal(remaining, 0);
      assert.equal(balance, 10);
    });
  });

  describe("should check withdraw function", async () => {
    it("should check that only owner can withdraw from smart contract", async () => {
      await timeMachine.advanceBlockAndSetTime(1852848590);
      await truffleAssert.reverts(
        sale.withdraw(accounts[0], { from: accounts[2] }),
        "Ownable: caller is not the owner"
      );
    });

    it("should check that owner cannot withdraw from smart contract before sale has ended", async () => {
      await timeMachine.advanceBlockAndSetTime(1552848590);
      await truffleAssert.reverts(
        sale.withdraw(accounts[0], { from: accounts[1] }),
        "Sale hasn't ended"
      );
    });

    it("should check the if correct amount is withdrawn", async () => {
      await timeMachine.advanceBlockAndSetTime(1852848590);
      await truffleAssert.passes(
        sale.withdraw(accounts[2], { from: accounts[1] })
      );
      let balance = await usdc.balanceOf(accounts[2]);
      assert.equal(balance, 10 );
    });
  });
});
