// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

// Contracts
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
        vm.startBroadcast(privateKey);

        address deployer = vm.addr(privateKey);

        AccountLogic logic = new AccountLogic();
        console.log("Logic deployed at:", address(logic));

        bytes memory initData = abi.encodeWithSignature(
            "initialize(address,string)",
            msg.sender,
            "Initial Data"
        );

        // Deploy Marketplace
        MarketPlace marketplace = new MarketPlace(payable(deployer));
        console.log("MarketPlace deployed at:", address(marketplace));

        // Deploy InsurancePolicyFactory with marketplace address
        InsurancePolicyFactory policyFactory = new InsurancePolicyFactory(address(marketplace));
        console.log("InsurancePolicyFactory deployed at:", address(policyFactory));

        // Deploy ClaimsAutomation
        ClaimsAutomation automation = new ClaimsAutomation();
        console.log("ClaimsAutomation deployed at:", address(automation));

        // Deploy proxy contract
        AccountProxy proxy = new AccountProxy(address(logic), initData);
        console.log("Proxy deployed at:", address(proxy));

        // Deploy Profile contract
        Profile profile = new Profile(address(proxy));
        console.log("Profile contract deployed at:", address(profile));

        vm.stopBroadcast();
    }
}
