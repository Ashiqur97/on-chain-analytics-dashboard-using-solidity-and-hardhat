const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy Analytics (main contract)
  console.log("Deploying Analytics...");
  const Analytics = await hre.ethers.getContractFactory("Analytics");
  const analytics = await Analytics.deploy();
  await analytics.deployed();
  console.log("Analytics deployed to:", analytics.address);

  // Deploy DataAggregator
  console.log("Deploying DataAggregator...");
  const DataAggregator = await hre.ethers.getContractFactory("DataAggregator");
  const aggregator = await DataAggregator.deploy(analytics.address);
  await aggregator.deployed();
  console.log("DataAggregator deployed to:", aggregator.address);

  // Deploy DataProvider
  console.log("Deploying DataProvider...");
  const DataProvider = await hre.ethers.getContractFactory("DataProvider");
  const dataProvider = await DataProvider.deploy(analytics.address);
  await dataProvider.deployed();
  console.log("DataProvider deployed to:", dataProvider.address);

  // Setup permissions
  console.log("Setting up permissions...");
  await analytics.addDataProvider(aggregator.address);
  await analytics.addDataProvider(dataProvider.address);
  console.log("Authorized DataAggregator and DataProvider as data providers");

  // Verify contracts on Etherscan (if not on localhost)
  if (hre.network.name !== "localhost" && hre.network.name !== "hardhat") {
    console.log("Waiting for block confirmations...");
    // Wait for 5 block confirmations before verification
    await analytics.deployTransaction.wait(5);
    
    console.log("Verifying contracts on Etherscan...");
    
    try {
      await hre.run("verify:verify", {
        address: analytics.address,
        constructorArguments: [],
      });
    } catch (error) {
      console.log("Error verifying Analytics:", error.message);
    }

    try {
      await hre.run("verify:verify", {
        address: aggregator.address,
        constructorArguments: [analytics.address],
      });
    } catch (error) {
      console.log("Error verifying DataAggregator:", error.message);
    }

    try {
      await hre.run("verify:verify", {
        address: dataProvider.address,
        constructorArguments: [analytics.address]
      });
    } catch (error) {
      console.log("Error verifying DataProvider:", error.message);
    }
  }

  console.log("\nDeployment completed successfully!");
  console.log("\nContract addresses:");
  console.log("Analytics:", analytics.address);
  console.log("DataAggregator:", aggregator.address);
  console.log("DataProvider:", dataProvider.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
