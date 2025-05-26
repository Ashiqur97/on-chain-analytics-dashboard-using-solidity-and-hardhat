// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PriceOracle {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }
    

    mapping (address => uint256) public prices;
    mapping (address => address) public priceUpdaters;
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

    function setPriceUpdater(address _token, address _updater) external onlyOwner {
        require(_token != address(0), "Invalid token address");
        require(_updater != address(0), "Invalid updater address");
        priceUpdaters[_token] = _updater;
        emit PriceUpdaterSet(_token, _updater);
    }

}