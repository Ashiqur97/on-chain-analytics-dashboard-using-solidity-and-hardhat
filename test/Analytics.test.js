const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("Analytics Dashboard", function() {
    let Analytics,DataAggregator,DataProvider;
    let analytics,dataAggregator,dataProvider;
    let owner,addr1,addr2;

    beforeEach(async function() {
        [owner,addr1,addr2] = await ethers.getSigners();

        Analytics = await ethers.getContractFactory("Analytics");
        analytics = await Analytics.deploy();
        await analytics.deployed();

        DataAggregator = await ethers.getContractFactory("DataAggregator");
        dataAggregator = await DataAggregator.deploy();
        await dataAggregator.deployed();

        DataProvider = await ethers.getContractFactory("DataProvider");
        dataProvider = await DataProvider.deploy();
        await dataProvider.deployed();

        await analytics.addDataProvider(dataAggregator.address);
        await analytics.addDataProvider(dataProvider.address);
    });

    describe("Basic Setup", function () {
        it("Should set the right owner", async function () {
            expect(await analytics.owner()).to.equal(owner.address);
        });

        it("Should authorize data providers", async function () {
      expect(await analytics.dataProviders(dataProvider.address)).to.be.true;
      expect(await analytics.dataProviders(dataAggregator.address)).to.be.true;
    });
    });

      describe("Token Management", function () {
    const tokenAddress = "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6";
    const tokenName = "Test Token";
    const price = ethers.utils.parseEther("100");
    const volume = ethers.utils.parseEther("1000000");
    const holders = 1000;
    const marketCap = ethers.utils.parseEther("10000000");

    it("Should update token data through DataProvider", async function () {
      // Submit token data through DataProvider
      await dataProvider.submitTokenData(
        tokenAddress,
        tokenName,
        price,
        volume,
        holders
      );

      // Verify token data in Analytics contract
      const tokenData = await analytics.tokens(tokenAddress);
      expect(tokenData.name).to.equal(tokenName);
      expect(tokenData.price).to.equal(price);
      expect(tokenData.volume).to.equal(volume);
      expect(tokenData.holders).to.equal(holders);
    });

    it("Should update token metrics through DataAggregator", async function () {
      // Submit token metrics through DataAggregator
      await dataAggregator.updateTokenMetrics(
        tokenAddress,
        price,
        volume,
        marketCap,
        holders
      );

      // Verify token data in Analytics contract
      const tokenData = await analytics.tokens(tokenAddress);
      expect(tokenData.price).to.equal(price);
      expect(tokenData.volume).to.equal(volume);
      expect(tokenData.holders).to.equal(holders);
    });
  });

})