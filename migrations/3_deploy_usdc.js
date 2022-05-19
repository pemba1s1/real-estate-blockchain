var USDC = artifacts.require("./Usdc.sol");

module.exports = function (deployer) {
  deployer.deploy(USDC);
};
