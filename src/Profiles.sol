// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {IAccountProxy} from "./interfaces/IImplementation.sol";

contract Profile is EIP712 {
    IAccountProxy public iAccountProxy;
    uint16 public insuranceCompanyCount;
    uint16 public userCount;

    struct InsuranceCompany {
        string name;
        string img;
        uint16 id;
        address owner;
        uint256 createdAt;
    }

    struct UserProfile {
        string username;
        string img;
        uint16 id;
        address owner;
        uint256 createdAt;
        bool isSeller;
    }

    mapping(address => bool) public isInsuranceCompany;
    mapping(address => bool) public isUser;
    mapping(uint16 => InsuranceCompany) public allInsuranceCompanies;
    mapping(uint16 => UserProfile) public allUserProfiles;

    event InsuranceCompanyCreated(address indexed company);
    event UserProfileCreated(address indexed user);
    event UserProfileUpdated(address indexed user);

    constructor(address _accountProxy) EIP712("Profile", "1") {
        iAccountProxy = IAccountProxy(_accountProxy);
        insuranceCompanyCount = 0;
        userCount = 0;
    }

    function onboardInsuranceCompany(
        address company,
        string memory name,
        string memory img
    ) public {
        require(company == msg.sender, "Not Authorized");
        require(!isInsuranceCompany[company], "Company already onboarded");

        insuranceCompanyCount += 1;
        allInsuranceCompanies[insuranceCompanyCount] = InsuranceCompany(
            name,
            img,
            insuranceCompanyCount,
            msg.sender,
            block.timestamp
        );

        isInsuranceCompany[company] = true;
        emit InsuranceCompanyCreated(company);
    }

    function onboardUser(
        address user,
        string memory username,
        string memory img,
        bool _isSeller
    ) public {
        require(user == msg.sender, "Not Authorized");
        require(!isUser[user], "User already onboarded");

        userCount += 1;
        allUserProfiles[userCount] = UserProfile(
            username,
            img,
            userCount,
            msg.sender,
            block.timestamp,
            _isSeller
        );

        isUser[user] = true;
        emit UserProfileCreated(user);
    }

    function fetchInsuranceCompany(
        uint16 _id
    ) public view returns (InsuranceCompany memory) {
        require(
            _id > 0 && _id <= insuranceCompanyCount,
            "Insurance company not found"
        );
        return allInsuranceCompanies[_id];
    }

    function fetchUserProfile(
        uint16 _id
    ) public view returns (UserProfile memory) {
        require(_id > 0 && _id <= userCount, "User profile not found");
        return allUserProfiles[_id];
    }

    function updateUserProfile(string memory _img, uint16 _id) public {
        require(isUser[msg.sender], "Not a registered user");

        UserProfile storage profile = allUserProfiles[_id];
        require(profile.owner == msg.sender, "Not authorized");

        profile.img = _img;
        emit UserProfileUpdated(msg.sender);
    }
}
