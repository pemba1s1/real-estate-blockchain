const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");

const RealEstateToken = artifacts.require("./RealEstateToken.sol");

require("chai").use(require("chai-as-promised")).should();

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("RealEstateToken", function (accounts) {
  let token;
  before(async () => {
    token = await RealEstateToken.new(
      "TestToken",
      "TT",
      90,
      1,
      1651823937,
      1751823937,
      "TestNft",
      "TN",
      accounts[1]
    );
  });

  // it("check if token name is TestToken", async function () {
  //   const name = await token.name();
  //   assert.equal(name, "TestToken");
  // });

  it("check if token name is TestToken", async function () {
    const name = await token.name();
    assert.equal(name, "TestToken");
  });

  it("check if token symbol is TT", async function () {
    const symbol = await token.symbol();
    assert.equal(symbol, "TT");
  });

  it("check if total supply is 90*10**18", async function () {
    const totalSupply = await token.totalSupply();
    assert.equal(totalSupply, 90 * 10 ** 18);
  });

  it("check if total supply if provided to owner", async function () {
    const ownerSupply = await token.balanceOf(accounts[1]);
    assert.equal(ownerSupply, 90 * 10 ** 18);
  });

  it("check if nft name is TestNft", async function () {
    const name = await token.nftName();
    assert.equal(name, "TestNft");
  });

  it("check if nft symbol is TN", async function () {
    const symbol = await token.nftSymbol();
    assert.equal(symbol, "TN");
  });

  it("check if decimals is 18", async function () {
    const decimals = await token.decimals();
    assert.equal(decimals, 18);
  });

  it("check if initial price is 1", async function () {
    const initialPrice = await token.initialPrice();
    assert.equal(initialPrice, 1);
  });

  it("check if account without enough balace can transfer", async () => {
    await truffleAssert.reverts(
      token.transfer(accounts[0], 1, { from: accounts[3] }),
      "Amount exceeds balance"
    );
  });

  it("check if account with enough balance can transfer", async function () {
    await truffleAssert.passes(
      token.transfer(accounts[0], 1, { from: accounts[1] })
    );
    const balance = await token.balanceOf(accounts[0]);
    assert.equal(balance, 1 * 10 ** 18);
  });

  it("Check if error is thrown if token sent to null address", async () => {
    const nullAddress = "0x0000000000000000000000000000000000000000";
    await truffleAssert.reverts(
      token.transfer(nullAddress, 1, { from: accounts[1] }),
      "transfer to the zero address"
    );
  });

  it("Check if error is thrown if negative value to transfer is given", async () => {
    await truffleAssert.fails(
      token.transfer(accounts[2], -1, { from: accounts[0] })
    );
  });

  it("check if owner is account[1]", async () => {
    const owner = await token.getOwner();
    assert.equal(owner, accounts[1]);
  });

  it("check if account without enough balace can give allowance", async () => {
    await truffleAssert.reverts(
      token.approve(accounts[0], 1, { from: accounts[3] }),
      "not enough token"
    );
  });

  it("check if account with enough balance can give allowance", async function () {
    await truffleAssert.passes(
      token.approve(accounts[0], 1, { from: accounts[1] })
    );
    const balance = await token.allowance(accounts[1], accounts[0]);
    assert.equal(balance, 1 * 10 ** 18);
  });

  it("Check if error is thrown if negative value to allowance is given", async () => {
    await truffleAssert.fails(
      token.approve(accounts[2], -1, { from: accounts[0] })
    );
  });

  it("check if error is thrown if allowance is decreased below 0", async () => {
    await truffleAssert.passes(
      token.approve(accounts[0], 2, { from: accounts[1] })
    );
    await truffleAssert.reverts(
      token.decreaseAllowance(accounts[0], 3, { from: accounts[1] }),
      "Allowance cannot be less than zero"
    );
  });
});
