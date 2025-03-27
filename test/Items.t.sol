// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../src/Items.sol";

contract ItemsTest is Test {
    MarketPlace marketPlace;
    address owner;
    address buyer;
    address seller;

    uint256 listingPrice = 0.01 ether;

    function setUp() public {
        owner = address(this);
        buyer = vm.addr(1);
        seller = vm.addr(2);

        marketPlace = new MarketPlace(payable(owner));
    }

    function testCreateItem() public {
        vm.prank(seller);

        string memory itemName = "Car";
        string memory _description = "This is a description";

        marketPlace.CreateItem(
            itemName,
            _description,
            1,
            listingPrice,
            "https://cloudinary.com/images",
            false,
            0
        );

        (
            uint256 itemId,
            string memory name,
            uint16 sellerId,
            uint256 price,
            string memory mainImage,
            string memory description,
            uint256 createdAt,
            bool isUsed,
            uint16 monthsOfUsage,
            address itemSeller,
            bool isSold
        ) = marketPlace.idToMarketplace(1);

        assertEq(itemId, 1);
        assertEq(name, "Car");
        assertEq(price, listingPrice);
        assertEq(mainImage, "https://cloudinary.com/images");
        assertEq(description, "This is a description");
        assertEq(itemSeller, seller);
        assertFalse(isUsed);
        assertFalse(isSold);
    }

    function testFetchMarketplaceItems() public {
        vm.prank(seller);
        marketPlace.CreateItem(
            "Laptop",
            "A fast laptop",
            1,
            2 ether,
            "https://cloudinary.com/laptop",
            false,
            0
        );
        marketPlace.CreateItem(
            "Phone",
            "A great smartphone",
            1,
            1 ether,
            "https://cloudinary.com/phone",
            false,
            0
        );

        MarketPlace.Item[] memory items = marketPlace.fetchMarketplaceItems();

        assertEq(items.length, 2);
        assertEq(items[0].name, "Laptop");
        assertEq(items[1].name, "Phone");
    }

    function testFetchItemById() public {
        vm.prank(seller);
        marketPlace.CreateItem(
            "Watch",
            "Luxury watch",
            1,
            3 ether,
            "https://cloudinary.com/watch",
            false,
            0
        );

        MarketPlace.Item memory item = marketPlace.fetchItemById(1);

        assertEq(item.itemId, 1);
        assertEq(item.name, "Watch");
        assertEq(item.price, 3 ether);
    }

    function testPurchaseItem() public {
        vm.prank(seller);
        marketPlace.CreateItem(
            "Tablet",
            "A powerful tablet",
            1,
            2 ether,
            "https://cloudinary.com/tablet",
            false,
            0
        );

        vm.deal(buyer, 5 ether); // Give buyer enough ETH
        vm.prank(buyer);
        marketPlace.purchaseItem{value: 2 ether}(1);

        (, , , , , , , , , , bool isSold) = marketPlace.idToMarketplace(1);
        assertTrue(isSold);
    }

    function testDeleteItem() public {
        vm.prank(seller);
        marketPlace.CreateItem(
            "Headphones",
            "Noise cancelling",
            1,
            1 ether,
            "https://cloudinary.com/headphones",
            false,
            0
        );

        vm.prank(seller);
        marketPlace.deleteItem(1);

        vm.expectRevert("Item does not exist");
        marketPlace.fetchItemById(1);
    }

    function testUpdateItem() public {
        vm.prank(seller);
        marketPlace.CreateItem(
            "Speaker",
            "Wireless speaker",
            1,
            1.5 ether,
            "https://cloudinary.com/speaker",
            false,
            0
        );

        vm.prank(seller);
        marketPlace.updateItem(
            1,
            "Bluetooth Speaker",
            2 ether,
            "Updated description"
        );

        MarketPlace.Item memory updatedItem = marketPlace.fetchItemById(1);
        assertEq(updatedItem.name, "Bluetooth Speaker");
        assertEq(updatedItem.price, 2 ether);
        assertEq(updatedItem.description, "Updated description");
    }
}
