// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Profiles.sol";

contract ProfileTest is Test {
    Profile profile;
    address owner;
    address insuranceCompany;
    address user;
    address anotherUser;

    function setUp() public {
        owner = address(this);
        insuranceCompany = vm.addr(1);
        user = vm.addr(2);
        anotherUser = vm.addr(3);

        profile = new Profile(owner);
    }

    function testOnboardInsuranceCompany() public {
        vm.prank(insuranceCompany);
        profile.onboardInsuranceCompany(
            insuranceCompany,
            "InsureCo",
            "https://image.com/insureco.png"
        );

        Profile.InsuranceCompany memory company = profile.fetchInsuranceCompany(
            1
        );

        assertEq(company.id, 1);
        assertEq(company.name, "InsureCo");
        assertEq(company.owner, insuranceCompany);
    }

    function testOnboardUser() public {
        vm.prank(user);
        profile.onboardUser(
            user,
            "JohnDoe",
            "https://image.com/johndoe.png",
            true
        );

        Profile.UserProfile memory userProfile = profile.fetchUserProfile(1);

        assertEq(userProfile.id, 1);
        assertEq(userProfile.username, "JohnDoe");
        assertTrue(userProfile.isSeller);
        assertEq(userProfile.owner, user);
    }

    function testUpdateUserProfile() public {
        vm.prank(user);
        profile.onboardUser(
            user,
            "JohnDoe",
            "https://image.com/johndoe.png",
            true
        );

        vm.prank(user);
        profile.updateUserProfile("https://image.com/new_johndoe.png", 1);

        Profile.UserProfile memory updatedProfile = profile.fetchUserProfile(1);
        assertEq(updatedProfile.img, "https://image.com/new_johndoe.png");
    }

    function testCannotOnboardSameUserTwice() public {
        vm.prank(user);
        profile.onboardUser(
            user,
            "JohnDoe",
            "https://image.com/johndoe.png",
            true
        );

        vm.prank(user);
        vm.expectRevert("User already onboarded");
        profile.onboardUser(
            user,
            "JohnDoe",
            "https://image.com/johndoe.png",
            true
        );
    }

    function testCannotUpdateAnotherUsersProfile() public {
        vm.prank(user);
        profile.onboardUser(
            user,
            "JohnDoe",
            "https://image.com/johndoe.png",
            true
        );

        vm.prank(anotherUser);
        vm.expectRevert("Not authorized");
        profile.updateUserProfile("https://image.com/hacker.png", 1);
        vm.prank(user);
        profile.onboardUser(
            user,
            "JohnDoe",
            "https://image.com/johndoe.png",
            true
        );

        vm.prank(anotherUser);
        profile.onboardUser(
            anotherUser,
            "Hacker",
            "https://image.com/hacker.png",
            false
        ); // Onboard anotherUser first

        vm.prank(anotherUser);
        vm.expectRevert("Not authorized");
        profile.updateUserProfile("https://image.com/hacker.png", 1);
    }

    function testCannotFetchNonExistentUser() public {
        vm.expectRevert("User profile not found");
        profile.fetchUserProfile(1);
    }

    function testCannotFetchNonExistentInsuranceCompany() public {
        vm.expectRevert("Insurance company not found");
        profile.fetchInsuranceCompany(1);
    }
}
