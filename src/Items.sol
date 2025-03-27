// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MarketPlace {
    uint256 private itemIds;
    address payable owner;

    struct Item {
        uint256 itemId;
        string name;
        uint16 sellerId;
        uint256 price;
        string mainImage;
        string description;
        uint256 createdAt;
        bool isUsed;
        uint16 monthsOfUsage;
        address seller;
        bool isSold;
    }

    mapping(uint256 => Item) public idToMarketplace;

    // Events
    event ItemCreated(
        uint256 indexed itemId,
        string name,
        uint16 indexed sellerId,
        uint256 price,
        string description,
        uint256 createdAt
    );

    event ItemSold(
        uint256 indexed itemId,
        uint16 indexed sellerId,
        address indexed buyer,
        uint256 price,
        uint256 soldAt
    );

    event ItemDeleted(uint256 indexed itemId, address indexed seller);
    event ItemUpdated(
        uint256 indexed itemId,
        string name,
        uint256 price,
        string description
    );

    constructor(address payable marketOwner) {
        owner = marketOwner;
    }

    function CreateItem(
        string memory _name,
        string memory _description,
        uint16 _sellerId,
        uint256 _price,
        string memory _mainImg,
        bool _isUsed,
        uint16 _monthsOfUsage
    ) public {
        require(_price > 0, "Price must be greater than 0");

        itemIds += 1;
        uint256 itemId = itemIds;

        idToMarketplace[itemId] = Item(
            itemId,
            _name,
            _sellerId,
            _price,
            _mainImg,
            _description,
            block.timestamp,
            _isUsed,
            _monthsOfUsage,
            msg.sender,
            false
        );

        emit ItemCreated(
            itemId,
            _name,
            _sellerId,
            _price,
            _description,
            block.timestamp
        );
    }

    // Fetch all marketplace items
    function fetchMarketplaceItems() public view returns (Item[] memory) {
        Item[] memory items = new Item[](itemIds);
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= itemIds; i++) {
            if (!idToMarketplace[i].isSold) {
                items[currentIndex] = idToMarketplace[i];
                currentIndex++;
            }
        }
        return items;
    }

    // Fetch a single item by itemId
    function fetchItemById(uint256 _itemId) public view returns (Item memory) {
        require(
            idToMarketplace[_itemId].seller != address(0),
            "Item does not exist"
        );
        return idToMarketplace[_itemId];
    }

    // Purchase an item
    function purchaseItem(uint256 _itemId) public payable {
        require(_itemId > 0 && _itemId <= itemIds, "Item does not exist");
        Item storage item = idToMarketplace[_itemId];

        require(!item.isSold, "Item already sold");
        require(msg.value >= item.price, "Insufficient funds");

        payable(item.seller).transfer(msg.value);
        item.isSold = true;

        emit ItemSold(
            _itemId,
            item.sellerId,
            msg.sender,
            item.price,
            block.timestamp
        );
    }

    // Delete an item (Only seller or owner can delete)
    function deleteItem(uint256 _itemId) public {
        require(_itemId > 0 && _itemId <= itemIds, "Item does not exist");
        Item storage item = idToMarketplace[_itemId];

        require(
            msg.sender == item.seller || msg.sender == owner,
            "Not authorized to delete this item"
        );

        delete idToMarketplace[_itemId];

        emit ItemDeleted(_itemId, msg.sender);
    }

    // Update an item (Only seller can update)
    function updateItem(
        uint256 _itemId,
        string memory _name,
        uint256 _price,
        string memory _description
    ) public {
        require(_itemId > 0 && _itemId <= itemIds, "Item does not exist");
        Item storage item = idToMarketplace[_itemId];

        require(msg.sender == item.seller, "Only seller can update item");
        require(!item.isSold, "Cannot update sold item");

        item.name = _name;
        item.price = _price;
        item.description = _description;

        emit ItemUpdated(_itemId, _name, _price, _description);
    }
}
