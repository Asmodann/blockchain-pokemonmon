// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

uint256 constant UnusedID = 0;
uint256 constant BulbasaurID = 1;
uint256 constant IvysaurID = 2;
uint256 constant VenusaurID = 3;
uint256 constant CharmanderID = 4;
uint256 constant CharmeleonID = 5;
uint256 constant CharizardID = 6;
uint256 constant SquirtleID = 7;
uint256 constant WartortleID = 8;
uint256 constant BlastoiseID = 9;

struct pokemonAttribute {
    string _name;
    string _value;
    bool _isUpdatable;
}

struct pokemon {
    uint256 _id;
    string _name;
    bool _isClaimable;
    uint256 _evolveId;
    pokemonAttribute[] _attributes;
}

contract Pokemon {
    modifier pokemonExist(uint256 _id) {
        require(_id > 0, "This pokemon doesn't exists.");
        _;
    }

    modifier pokemonNotExist(uint256 _id) {
        require(_id == 0, "This pokemon already exists.");
        _;
    }
}