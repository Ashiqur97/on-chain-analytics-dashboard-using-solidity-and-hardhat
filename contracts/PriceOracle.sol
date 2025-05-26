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

    function updatePrice(address _token, uint256 _price) external {
        require(msg.sender == owner || msg.sender == priceUpdaters[_token], "Not authorized");
        require(_price > 0, "Invalid price");
        prices[_token] = _price;
        lastUpdateTimestamp[_token] = block.timestamp;
        emit PriceUpdated(_token, _price);
    }

        function getPrice(address _token) external view returns (Price memory) {
        uint256 price = prices[_token];
        uint256 timestamp = lastUpdateTimestamp[_token];
        
        if (price > 0 && block.timestamp - timestamp <= PRICE_EXPIRATION) {
            return Price({
                price: price,
                timestamp: timestamp,
                success: true
            });
        }
        
        return Price({
            price: 0,
            timestamp: 0,
            success: false
        });
    }

       function getPriceWithHeartbeat(address _token, uint256 _maxAge) external view returns (Price memory) {
        Price memory price = this.getPrice(_token);
        require(price.success, "Price fetch failed");
        require(block.timestamp - price.timestamp <= _maxAge, "Price too old");
        return price;
    }

    function getBatchPrices(address[] calldata _tokens) external view returns (Price[] memory) {
        Price[] memory priceList = new Price[](_tokens.length);
        
        for (uint256 i = 0; i < _tokens.length; i++) {
            priceList[i] = this.getPrice(_tokens[i]);
        }
        
        return priceList;
    }

}