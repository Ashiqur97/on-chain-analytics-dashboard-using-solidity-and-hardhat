const { expect } = require("chai");
const { ethers } = require("hardhat");

// Import ethers directly
const { utils } = require("ethers");

// Helper function to parse ether values
const parseEther = (value) => {
  return utils.parseEther(value.toString());
};

describe("Analytics Dashboard", function () {
  let Analytics, DataAggregator, DataProvider;
  let analytics, dataAggregator, dataProvider;
  let owner, addr1, addr2;

  beforeEach(async function () {
    // Get signers
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy Analytics contract
    Analytics = await ethers.getContractFactory("Analytics");
    analytics = await Analytics.deploy();
    await analytics.deployed();

    // Deploy DataAggregator
    DataAggregator = await ethers.getContractFactory("DataAggregator");
    dataAggregator = await DataAggregator.deploy(analytics.address);
    await dataAggregator.deployed();

    // Deploy DataProvider
    DataProvider = await ethers.getContractFactory("DataProvider");
    dataProvider = await DataProvider.deploy(analytics.address);
    await dataProvider.deployed();

    // Setup permissions
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
    const tokenAddress = "0x1234567890123456789012345678901234567890";
    const tokenName = "Test Token";
    const price = parseEther("100");
    const volume = parseEther("1000000");
    const marketCap = parseEther("10000000");
    const holders = 1000;

    it("Should update token data through DataProvider", async function () {
      // Submit token data through DataProvider
      await dataProvider.submitTokenData(
        tokenAddress,
        tokenName,
        price,
        volume,
        marketCap,
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

  describe("Protocol Management", function () {
    const protocolAddress = "0x9876543210987654321098765432109876543210";
    const protocolName = "Test Protocol";
    const tvl = ethers.utils.parseEther("5000000");
    const volume24h = ethers.utils.parseEther("2000000");
    const uniqueUsers = 5000;

    it("Should update protocol data through DataProvider", async function () {
      // Submit protocol data through DataProvider
      await dataProvider.submitProtocolData(
        protocolAddress,
        protocolName,
        tvl,
        uniqueUsers
      );

      // Verify protocol data in Analytics contract
      const protocolData = await analytics.protocols(protocolAddress);
      expect(protocolData.name).to.equal(protocolName);
      expect(protocolData.tvl).to.equal(tvl);
      expect(protocolData.users).to.equal(uniqueUsers);
    });

    it("Should update protocol metrics through DataAggregator", async function () {
      // Submit protocol metrics through DataAggregator
      await dataAggregator.updateProtocolMetrics(
        protocolAddress,
        tvl,
        volume24h,
        uniqueUsers
      );

      // Verify protocol metrics in Analytics contract
      const protocolData = await analytics.protocols(protocolAddress);
      expect(protocolData.tvl).to.equal(tvl);
      expect(protocolData.users).to.equal(uniqueUsers);
      
      // Verify protocol metrics through IAnalyticsRegistry view functions
      expect(await analytics.protocolTVL(protocolAddress)).to.equal(tvl);
      expect(await analytics.protocolVolume24h(protocolAddress)).to.equal(volume24h);
      expect(await analytics.protocolUniqueUsers(protocolAddress)).to.equal(uniqueUsers);
    });
  });

  describe("Access Control", function () {
    it("Should not allow unauthorized access to update functions", async function () {
      // First, remove the data provider's authorization
      await analytics.removeDataProvider(dataProvider.address);
      
      // Use a valid token address for testing
      const testTokenAddress = "0x1234567890123456789012345678901234567890";
      
      // Now try to call update functions from an unauthorized address
      await expect(
        dataProvider.connect(addr1).submitTokenData(
          testTokenAddress,
          "Test Token",
          0,
          0,
          0,
          0
        )
      ).to.be.revertedWith("Not authorized");

      // Remove aggregator's authorization
      await analytics.removeDataProvider(dataAggregator.address);
      
      await expect(
        dataAggregator.connect(addr1).updateTokenMetrics(
          testTokenAddress,
          0,
          0,
          0,
          0
        )
      ).to.be.revertedWith("Not authorized");
    });
  });
});
