// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/InsurancePolicy.sol";

interface IMarketplaceMock {
    function fetchItemsById(uint256 itemId) external view returns (
        uint256, string memory, uint256, uint256, string memory,
        string memory, uint256, bool, uint16, address, bool
    );
}

contract InsurancePolicyTest is Test {
    InsurancePolicyFactory factory;
    InsurancePolicy policy;
    ClaimsAutomation automation;
    address payable insured = payable(address(0x123));
    address payable insurer = payable(address(0x456));
    address payable anotherUser = payable(address(0x789));
    address owner = address(this);

    uint256 premium = 1 ether;
    uint256 coverageAmount = 5 ether;
    uint256 duration = 5; // 5 days
    string policyType = "FLIGHT_DELAY";
    uint256 itemId = 1;

    IMarketplaceMock marketplace;

    function setUp() public {
        // deploy a dummy marketplace
        marketplace = IMarketplaceMock(address(this));
        factory = new InsurancePolicyFactory(address(marketplace));
        automation = new ClaimsAutomation();
    }

    // Dummy implementation for mock
    function fetchItemsById(uint256) external view returns (
        uint256, string memory, uint256, uint256, string memory,
        string memory, uint256, bool, uint16, address, bool
    ) {
        return (1, "Item", 1, premium, "img", "desc", block.timestamp, false, 3, address(0x999), true);
    }

    function testCreatePolicy() public {
        address policyAddress = factory.createPolicy(
            insured,
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            address(0),
            itemId
        );
        assertEq(factory.getAllPolicies().length, 1);
        assertEq(factory.getUserPolicies(insured).length, 1);
        assertEq(factory.getUserPolicies(insured)[0], policyAddress);
    }

    function testPayPremiumAndActivatePolicy() public {
        address policyAddress = factory.createPolicy(
            insured,
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            address(0),
            itemId
        );
        policy = InsurancePolicy(payable(policyAddress));

        vm.prank(insured);
        vm.deal(insured, premium);
        policy.payPremium{value: premium}();

        assertTrue(policy.active());
        assertEq(policy.startTime(), block.timestamp);
        assertEq(policy.endTime(), block.timestamp + 1 days * duration);
    }

    function testMarkClaimableAndProcessPayout() public {
        address policyAddress = factory.createPolicy(
            insured,
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            address(0),
            itemId
        );
        policy = InsurancePolicy(payable(policyAddress));

        vm.prank(insured);
        vm.deal(insured, premium);
        policy.payPremium{value: premium}();

        automation.registerPolicy(address(policy));
        automation.triggerClaim(address(policy));

        assertTrue(policy.claimable());

        vm.deal(address(policy), coverageAmount);

        uint256 balanceBefore = insured.balance;

        vm.prank(insured);
        policy.processPayout();

        uint256 balanceAfter = insured.balance;

        assertTrue(policy.claimed());
        assertEq(balanceAfter - balanceBefore, coverageAmount);
    }

    function testOnlyInsuredCanPayPremium() public {
        address policyAddress = factory.createPolicy(
            insured,
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            address(0),
            itemId
        );
        policy = InsurancePolicy(payable(policyAddress));

        vm.expectRevert();
        vm.prank(anotherUser);
        policy.payPremium{value: premium}();
    }

    function testCannotClaimBeforeMarkedClaimable() public {
        address policyAddress = factory.createPolicy(
            insured,
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            address(0),
            itemId
        );
        policy = InsurancePolicy(payable(policyAddress));

        vm.prank(insured);
        vm.deal(insured, premium);
        policy.payPremium{value: premium}();

        vm.expectRevert("Not claimable yet");
        vm.prank(insured);
        policy.processPayout();
    }

    function testCreatePolicyForMarketplaceItem() public {
        address policyAddress = factory.createPolicyForMarketplaceItem(
            insured,
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            address(0),
            itemId
        );
        assertEq(factory.getPolicyByItemId(itemId), policyAddress);
    }

    function testFailCreatePolicyForUnsoldItem() public {
        // Override to return unsold item
        vm.mockCall(
            address(marketplace),
            abi.encodeWithSelector(marketplace.fetchItemsById.selector, itemId),
            abi.encode(1, "Item", 1, premium, "img", "desc", block.timestamp, false, 3, address(0x999), false)
        );

        factory.createPolicyForMarketplaceItem(
            insured,
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            address(0),
            itemId
        );
    }

    function testFailCreatePolicyBySeller() public {
        // Override to return seller == msg.sender (owner)
        vm.mockCall(
            address(marketplace),
            abi.encodeWithSelector(marketplace.fetchItemsById.selector, itemId),
            abi.encode(1, "Item", 1, premium, "img", "desc", block.timestamp, false, 3, owner, true)
        );

        factory.createPolicyForMarketplaceItem(
            payable(owner),
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            address(0),
            itemId
        );
    }
}

interface IIInsurancePolicy {
    function payPremium() external payable;
    function markClaimable() external;
    function processPayout() external;
    function active() external view returns (bool);
    function claimed() external view returns (bool);
    function claimable() external view returns (bool);
    function startTime() external view returns (uint256);
    function endTime() external view returns (uint256);
}