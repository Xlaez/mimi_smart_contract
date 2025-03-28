// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

// Contracts (update these import paths as needed)
import "../src/Items.sol";
import "../src/InsurancePolicy.sol";
import "../src/Profiles.sol";
import "../src/AccountProxy.sol";
import "../src/AccountLogic.sol";
import {IAccountProxy} from "../src/interfaces/IImplementation.sol";

contract Deployer is Script {
    function setUp() public {}

    function run() public {
        // Load private key
        string memory privateKeyStr = vm.envString("PRIVATE_KEY");
        uint256 privateKey = vm.parseUint(privateKeyStr);
        
        // Start broadcast with the private key
        vm.startBroadcast(privateKey);

        // Get the deployer address
        address deployer = vm.addr(privateKey);
        console.log("Deployer address:", deployer);

        // Deploy contracts
        AccountLogic logic = new AccountLogic();
        console.log("AccountLogic deployed at:", address(logic));

        bytes memory initData = abi.encodeWithSignature(
            "initialize(address,string)",
            deployer,
            "Initial Setup"
        );

        AccountProxy proxy = new AccountProxy(address(logic), initData);
        console.log("AccountProxy deployed at:", address(proxy));

        MarketPlace marketplace = new MarketPlace(payable(deployer));
        console.log("MarketPlace deployed at:", address(marketplace));

        InsurancePolicyFactory policyFactory = new InsurancePolicyFactory(address(marketplace));
        console.log("InsurancePolicyFactory deployed at:", address(policyFactory));

        ClaimsAutomation automation = new ClaimsAutomation();
        console.log("ClaimsAutomation deployed at:", address(automation));

        Profile profile = new Profile(address(proxy));
        console.log("Profile contract deployed at:", address(profile));

        vm.stopBroadcast();
    }
}