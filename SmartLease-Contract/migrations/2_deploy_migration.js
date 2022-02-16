var SmartLeaseContract = artifacts.require("SmartLeaseContract");

module.exports = function(deployer){
    deployer.deploy(SmartLeaseContract);
}