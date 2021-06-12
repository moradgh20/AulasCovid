let Escuela = artifacts.require("Escuela");

module.exports = function(_deployer) {
   _deployer.deploy(Escuela, "ETSIT");
};
