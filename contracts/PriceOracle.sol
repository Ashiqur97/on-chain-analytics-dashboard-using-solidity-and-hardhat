// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PriceOracle {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }
    

    mapping (address => uint256) public prices;
    mapping (address => address) public priceUpdates;
    mapping (address => uint256) public lastUpdateTimestamp;
    uint256 public constant PRICE_EXPIRATION = 24 hours;
    
    event PriceUpdated(address indexed token, uint256 price);
    event PriceUpdaterSet(address indexed token, address indexed updater);
    event PriceUpdated(address indexed token, uint256 price, uint256 timestamp);

    struct Price {
        uint256 price;
        uint256 timestamp;
        bool success;
    }

    constructor() {
        owner = msg.sender;
    }

}