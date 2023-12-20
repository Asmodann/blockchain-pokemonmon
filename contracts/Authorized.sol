// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Authorized is Ownable {
    mapping(address => bool) Authorizations;

    constructor(address _owner) Ownable(_owner) {
        Authorizations[_owner] = true;
    }

    function setOwner(address _owner) public onlyOwner {
        if (_owner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }

        _transferOwnership(_owner);
    }

    function addAuthorization(address _other) public onlyOwner {
        Authorizations[_other] = true;
    }

    function delAuthorization(address _other) public onlyOwner {
        delete Authorizations[_other];
    }

    modifier onlyAuthorized() {
        if (!Authorizations[msg.sender]) {
            revert();
        }
        _;
    }
}