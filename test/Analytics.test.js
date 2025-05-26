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

    
})