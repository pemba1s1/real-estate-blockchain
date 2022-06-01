var StakeTokenNFT = artifacts.require("./StakeTokenNFT.sol");

module.exports = function (deployer) {
  deployer.deploy(StakeTokenNFT);
};
