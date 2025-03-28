// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMarketplace {
    function fetchItemsById(uint256 itemId) external view returns(uint256, string memory, uint256, uint256, string memory, string memory, uint256, bool, uint16, address, bool);
}

contract InsurancePolicyFactory is Ownable {
    address[] public allPolicies;
    IMarketplace public marketplace;

    constructor(address _marketplace) Ownable(msg.sender) {
        marketplace = IMarketplace(_marketplace);
    }

    mapping(address => address[]) public userPolicies;
    mapping(uint256 => address) public itemIdToPolicy;

    event PolicyCreated(address indexed user, address policy);
    event PolicyCreatedForItem(address indexed user, uint256 indexed itemId, address policy);

    function createPolicy(
        address payable insured,
        address payable insurer,
        uint256 premium,
        uint256 coverageAmount,
        uint256 duration,
        string memory policyType,
        address payoutToken,
        uint256 marketPlaceItemId
    ) external onlyOwner returns (address policy) {
        InsurancePolicy newPolicy = new InsurancePolicy(
            insured,
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            payoutToken,
            marketPlaceItemId
        );
        allPolicies.push(address(newPolicy));
        userPolicies[insured].push(address(newPolicy));
        emit PolicyCreated(insured, address(newPolicy));
        return address(newPolicy);
    }

    function createPolicyForMarketplaceItem(
        address payable insured,
        address payable insurer,
        uint256 premium,
        uint256 coverageAmount,
        uint256 duration,
        string memory policyType,
        address payoutToken,
        uint256 marketplaceItemId
    ) external onlyOwner returns (address policy) {
        require(itemIdToPolicy[marketplaceItemId] == address(0), "Insurance already exists for this item");

        (, , , , , , , , , address seller, bool isSold) = marketplace.fetchItemsById(marketplaceItemId);

        require(isSold, "Item not yet sold, cannot purchase insurance for an item that is yet to be sold.");
        require(msg.sender != seller, "Seller cannot insure their own item");

        InsurancePolicy newPolicy = new InsurancePolicy(
            insured,
            insurer,
            premium,
            coverageAmount,
            duration,
            policyType,
            payoutToken,
            marketplaceItemId
        );
        allPolicies.push(address(newPolicy));
        userPolicies[insured].push(address(newPolicy));
        itemIdToPolicy[marketplaceItemId] = address(newPolicy);
        emit PolicyCreatedForItem(insured, marketplaceItemId, address(newPolicy));
        return address(newPolicy);
    }

    function getAllPolicies() external view returns (address[] memory) {
        return allPolicies;
    }

    function getUserPolicies(address user) external view returns (address[] memory) {
        return userPolicies[user];
    }

    function getPolicyByItemId(uint256 itemId) external view returns (address) {
        return itemIdToPolicy[itemId];
    }
}

/// @notice Represents an individual insurance contract
contract InsurancePolicy is ReentrancyGuard {
    address public insured;
    address public insurer;
    uint256 public premium;
    uint256 public coverageAmount;
    uint256 public marketPlaceItemId;
    uint256 public startTime;
    uint256 public endTime;
    string public policyType;
    bool public active;
    bool public claimable;
    bool public claimed;
    address public payoutToken;
    uint256 public duration;


    event PolicyActivated(address indexed user);
    event ClaimTriggered(address indexed user);
    event PayoutProcessed(address indexed user, uint256 amount);

    modifier onlyInsured() {
        require(msg.sender == insured, "Not the insured");
        _;
    }

    constructor(
        address payable _insured,
        address _insurer,
        uint256 _premium,
        uint256 _coverageAmount,
        uint256 _duration,
        string memory _policyType,
        address _payoutToken,
        uint256  _marketPlaceItemId
    ) {
        insured = _insured;
        insurer = _insurer;
        premium = _premium;
        coverageAmount = _coverageAmount;
        policyType = _policyType;
        duration = _duration;
        startTime = 0;
        endTime = 0;
        active = false;
        claimable = false;
        claimed = false;
        payoutToken = _payoutToken;
        marketPlaceItemId = _marketPlaceItemId;
    }

    function payPremium() external payable onlyInsured nonReentrant {
        require(!active, "Already activated");
        require(msg.value == premium, "Incorrect premium amount");

        startTime = block.timestamp;
        endTime = block.timestamp + 1 days * (duration);
        active = true;

        emit PolicyActivated(insured);
    }

    function markClaimable() external nonReentrant {
        require(active, "Policy not active");
        require(block.timestamp <= endTime, "Policy expired");
        claimable = true;
        emit ClaimTriggered(insured);
    }

    function processPayout() external nonReentrant onlyInsured {
        require(claimable, "Not claimable yet");
        require(!claimed, "Already claimed");

        claimed = true;

        if (payoutToken == address(0)) {
            (bool sent,) = payable(insured).call{value: coverageAmount}("");
            require(sent, "Failed to send payout");
        } else {
            IERC20(payoutToken).transfer(insured, coverageAmount);
        }

        emit PayoutProcessed(insured, coverageAmount);
    }
}

/// @notice Triggers insurance policies based on external conditions
contract ClaimsAutomation is Ownable {
    constructor() Ownable(msg.sender) {}

    mapping(address => bool) public validPolicies;

    event PolicyRegistered(address policy);
    event ConditionTriggered(address policy);

    function registerPolicy(address policy) external onlyOwner {
        validPolicies[policy] = true;
        emit PolicyRegistered(policy);
    }

    function triggerClaim(address policy) external onlyOwner {
        require(validPolicies[policy], "Invalid policy");
        InsurancePolicy(policy).markClaimable();
        emit ConditionTriggered(policy);
    }
}

interface IInsurancePolicy {
    function markClaimable() external;
}
