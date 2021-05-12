const GUArtMarket = artifacts.require("GUArtMarket");

contract("GU Art token", accounts => {
  it("Token metadata should be correct", async () => {
    let contract = await GUArtMarket.deployed();
    let name = await contract.name();
    let symbol = await contract.symbol();
    assert.equal(name, "GUArtMarket");
    assert.equal(symbol, "GUAM");
  });
});
