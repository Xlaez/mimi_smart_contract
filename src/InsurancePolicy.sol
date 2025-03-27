// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract InsurancePolicy {
    address public policyHolder;
    uint256 public premium;
    bool public isClaimed;

    constructor(uint256 _premium) {
        policyHolder = msg.sender;
        premium = _premium;
    }

    function claim() external {
        require(msg.sender == policyHolder, "Not the owner of this policy");
        require(!isClaimed, "Already claimed");
        isClaimed = true;

        /**
            Logic to payout the insurance here
        */
    }
}
