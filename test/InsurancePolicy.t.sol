// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/InsurancePolicy.sol";

contract InsurancePolicyTest is Test {
    InsurancePolicy policy;

    function setUp() public {
        policy = new InsurancePolicy(1 ether);
    }

    function testClaimOnce() public {
        policy.claim();
        assertTrue(policy.isClaimed());
    }
}
