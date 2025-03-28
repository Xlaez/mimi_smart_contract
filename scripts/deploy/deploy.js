const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Deploy AccountLogic
  const AccountLogicFactory = await hre.ethers.getContractFactory(
    "AccountLogic"
  );
  const accountLogic = await AccountLogicFactory.deploy();
  await accountLogic.waitForDeployment();
  const accountLogicAddress = await accountLogic.getAddress();
  console.log("AccountLogic deployed to:", accountLogicAddress);

  // Encode init data for proxy
  const initData = AccountLogicFactory.interface.encodeFunctionData(
    "initialize",
    [deployer.address, "Initial Setup"]
  );

  // Deploy AccountProxy
  const AccountProxyFactory = await hre.ethers.getContractFactory(
    "AccountProxy"
  );
  const accountProxy = await AccountProxyFactory.deploy(
    accountLogicAddress,
    initData
  );
  await accountProxy.waitForDeployment();
  const accountProxyAddress = await accountProxy.getAddress();
  console.log("AccountProxy deployed to:", accountProxyAddress);

  // Deploy MarketPlace
  const MarketPlaceFactory = await hre.ethers.getContractFactory("MarketPlace");
  const marketplace = await MarketPlaceFactory.deploy(deployer.address);
  await marketplace.waitForDeployment();
  const marketplaceAddress = await marketplace.getAddress();
  console.log("MarketPlace deployed to:", marketplaceAddress);

  // Deploy Profiles (constructor needs proxy address)
  const ProfilesFactory = await hre.ethers.getContractFactory("Profile");
  const profiles = await ProfilesFactory.deploy(accountProxyAddress);
  await profiles.waitForDeployment();
  const profilesAddress = await profiles.getAddress();
  console.log("Profiles deployed to:", profilesAddress);

  // Deploy InsurancePolicyFactory (constructor needs marketplace address)
  const InsuranceFactory = await hre.ethers.getContractFactory(
    "InsurancePolicyFactory"
  );
  const insuranceFactory = await InsuranceFactory.deploy(marketplaceAddress);
  await insuranceFactory.waitForDeployment();
  const insuranceFactoryAddress = await insuranceFactory.getAddress();
  console.log("InsurancePolicyFactory deployed to:", insuranceFactoryAddress);

  // Deploy ClaimsAutomation
  const ClaimsAutomationFactory = await hre.ethers.getContractFactory(
    "ClaimsAutomation"
  );
  const claimsAutomation = await ClaimsAutomationFactory.deploy();
  await claimsAutomation.waitForDeployment();
  const claimsAutomationAddress = await claimsAutomation.getAddress();
  console.log("ClaimsAutomation deployed to:", claimsAutomationAddress);

  // Optional: print all deployed addresses for frontend or .env
  console.log("\n Deployment Summary:");
  console.log("AccountLogic:           ", accountLogicAddress);
  console.log("AccountProxy:           ", accountProxyAddress);
  console.log("MarketPlace:            ", marketplaceAddress);
  console.log("Profiles:               ", profilesAddress);
  console.log("InsurancePolicyFactory: ", insuranceFactoryAddress);
  console.log("ClaimsAutomation:       ", claimsAutomationAddress);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Deployment error:", err);
    process.exit(1);
  });
