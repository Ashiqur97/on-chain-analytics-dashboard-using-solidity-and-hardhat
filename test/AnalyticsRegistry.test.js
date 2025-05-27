const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AnalyticsRegistry", function () {
  let AnalyticsRegistry;
  let registry;
  let owner;
  let aggregator;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, aggregator, addr1, addr2] = await ethers.getSigners();
    AnalyticsRegistry = await ethers.getContractFactory("AnalyticsRegistry");
    registry = await AnalyticsRegistry.deploy();
    await registry.deployed();
  });

  describe("Protocol Management", function () {
    it("Should add a protocol", async function () {
      const protocolName = "Test Protocol";
      await registry.addProtocol(addr1.address, protocolName);

      const protocol = await registry.protocols(addr1.address);
      expect(protocol.name).to.equal(protocolName);
      expect(protocol.contractAddress).to.equal(addr1.address);
    });

    it("Should update protocol metrics", async function () {
      const protocolName = "Test Protocol";
      await registry.addProtocol(addr1.address, protocolName);
      await registry.authorizeAggregator(aggregator.address);

      const tvl = ethers.utils.parseEther("1000000");
      const volume24h = ethers.utils.parseEther("500000");
      const users = 1000;

      await registry.connect(aggregator).updateProtocolMetrics(
        addr1.address,
        tvl,
        volume24h,
        users
      );

      const protocol = await registry.protocols(addr1.address);
      expect(protocol.tvl).to.equal(tvl);
      expect(protocol.volume24h).to.equal(volume24h);
      expect(protocol.uniqueUsers).to.equal(users);
    });
  });

  describe("Token Management", function () {
    it("Should add a token", async function () {
      const tokenSymbol = "TEST";
      await registry.addToken(addr1.address, tokenSymbol);

      const token = await registry.tokens(addr1.address);
      expect(token.symbol).to.equal(tokenSymbol);
    });

    it("Should update token metrics", async function () {
      const tokenSymbol = "TEST";
      await registry.addToken(addr1.address, tokenSymbol);
      await registry.authorizeAggregator(aggregator.address);

      const price = ethers.utils.parseEther("100");
      const volume24h = ethers.utils.parseEther("1000000");
      const marketCap = ethers.utils.parseEther("10000000");
      const holders = 5000;

      await registry.connect(aggregator).updateTokenMetrics(
        addr1.address,
        price,
        volume24h,
        marketCap,
        holders
      );

      const token = await registry.tokens(addr1.address);
      expect(token.price).to.equal(price);
      expect(token.volume24h).to.equal(volume24h);
      expect(token.marketCap).to.equal(marketCap);
      expect(token.holders).to.equal(holders);
    });
  });

  describe("Access Control", function () {
    it("Should authorize and revoke aggregators", async function () {
      await registry.authorizeAggregator(aggregator.address);
      expect(await registry.authorizedAggregators(aggregator.address)).to.be.true;

      await registry.revokeAggregator(aggregator.address);
      expect(await registry.authorizedAggregators(aggregator.address)).to.be.false;
    });

    it("Should prevent unauthorized updates", async function () {
      const tokenSymbol = "TEST";
      await registry.addToken(addr1.address, tokenSymbol);

      await expect(
        registry.connect(addr2).updateTokenMetrics(
          addr1.address,
          100,
          100,
          100,
          100
        )
      ).to.be.revertedWith("Not authorized aggregator");
    });
  });
});
