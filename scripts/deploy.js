const hre = require("hardhat");

async function main() {
    const Analytics = await hre.getContractFactory("Analytics");
    const analytics = await Analytics.deploy();
  await analytics.waitForDeployment();
  console.log("Analytics deployed to:", await analytics.getAddress());

  const DataAggregator = await hre.ethers.getContractFactory("DataAggregator");
  const dataAggregator = await DataAggregator.deploy();
  await dataAggregator.waitForDeployment();
  console.log("DataAggregator deployed to:", await dataAggregator.getAddress());

   const DataProvider = await hre.ethers.getContractFactory("DataProvider");
  const dataProvider = await DataProvider.deploy(await analytics.getAddress());
  await dataProvider.waitForDeployment();
  console.log("DataProvider deployed to:", await dataProvider.getAddress());

  // Setup permissions
  await analytics.addDataProvider(await aggregator.getAddress());
  await analytics.addDataProvider(await dataProvider.getAddress());
  console.log("Authorized DataAggregator and DataProvider as data providers");

  // Verify contracts on Etherscan (if not on localhost)
  if (hre.network.name !== "localhost" && hre.network.name !== "hardhat") {
    console.log("Verifying contracts on Etherscan...");
    
    await hre.run("verify:verify", {
      address: await analytics.getAddress(),
      constructorArguments: [],
    });

    await hre.run("verify:verify", {
      address: await aggregator.getAddress(),
      constructorArguments: [await analytics.getAddress()],
    });

    await hre.run("verify:verify", {
      address: await dataProvider.getAddress(),
      constructorArguments: [await analytics.getAddress()]
    });
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
