// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccountProxy {
    address public implementation;

    constructor(address _implementation, bytes memory _initData) {
        implementation = _implementation;
        (bool ok, ) = _implementation.delegatecall(_initData);
        require(ok, "Initialization failed");
    }

    function upgradeTo(address newImplementation) public {
        implementation = newImplementation;
    }

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "Implementation not set");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}