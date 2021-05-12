const GUArtMarket = artifacts.require("GUArtMarket");

module.exports = function(deployer) {
  deployer.deploy(GUArtMarket)
  .then(async (contract) => {
    await contract.registerArt('{"name":"Blade Trader Drosis","image":"https://card.godsunchained.com/?id=96&q=2&png=true"}');
    await contract.registerArt('{"name":"Neferu, Champion of Death","image":"https://card.godsunchained.com/?id=828&q=3&png=true"}');
	await contract.registerArt('{"name":"Test","image":"https://drive.google.com/file/d/1Z67cCXAQo7YROZQ-qrH3T0ztCv9XM1u6/view"}');
  });
};
