var TokenSale = artifacts.require("./TokenSale.sol");

module.exports = function (deployer) {
  deployer.deploy(TokenSale);
};
