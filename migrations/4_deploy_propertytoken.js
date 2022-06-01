var RealEstateToken = artifacts.require("./RealEstateToken.sol");

module.exports = function (deployer) {
  deployer.deploy(RealEstateToken);
};
