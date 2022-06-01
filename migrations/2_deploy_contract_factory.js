var ContractFactory = artifacts.require("./ContractFactory.sol");

module.exports = function (deployer) {
  deployer.deploy(ContractFactory,"0xa9Fb859C96e73aF81102b947AA550Df809CCd4eE","0xb5dabC535483888588509eF66dBf3070e6E214f1");
};
