// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract AccountLogic is Initializable {
    address public implementationOwner;
    string public someData;

    function initialize(address _owner, string memory _someData) public initializer {
        implementationOwner = _owner;
        someData = _someData;
    }

    function setSomeData(string memory _newData) public {
        require(msg.sender == implementationOwner, "Not authorized");
        someData = _newData;
    }
}
