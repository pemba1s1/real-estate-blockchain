const truffleAssertions = require("truffle-assertions");

const ContractFactory = artifacts.require("./ContractFactory");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ContractFactory", function (accounts) {
  let contractFactory;
  before(async () => {
    contractFactory = await ContractFactory.new();
  });

  it("should deploy real estate token contract", async () => {
    await truffleAssertions.passes(
      contractFactory.deployProperty(
        "TestToken",
        "TT",
        100000,
        1,
        1651823937,
        1751823937,
        "TestNft",
        "TN",
        accounts[1]
      )
    );
  });
  it("should not deploy real estate token contract", async () => {
    await truffleAssertions.fails(
      contractFactory.deployProperty(
        "TestToken",
        "TT",
        100000,
        1,
        1651823937,
        1751823937,
        "TestNft",
        "TN"
      )
    );
  });
});
