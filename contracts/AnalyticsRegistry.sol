// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AnalyticsRegistry
 * @dev Main registry contract for analytics data collection and management
 */
contract AnalyticsRegistry {
    address public owner;
    bool public paused;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract paused");
        _;
    }
    
    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }
    
    bool private locked;
    // Structs
    struct Protocol {
        string name;
        address contractAddress;
        uint256 tvl;
        uint256 volume24h;
        uint256 uniqueUsers;
        uint256 lastUpdated;
    }

    struct TokenMetrics {
        string symbol;
        uint256 price;
        uint256 volume24h;
        uint256 marketCap;
        uint256 holders;
        uint256 lastUpdated;
    }

    // State variables
    mapping(address => Protocol) public protocols;
    mapping(address => TokenMetrics) public tokens;
    mapping(address => bool) public authorizedAggregators;
    
    address[] public registeredProtocols;
    address[] public registeredTokens;

    // Events
    event ProtocolAdded(address indexed protocolAddress, string name);
    event ProtocolUpdated(address indexed protocolAddress, uint256 tvl, uint256 volume24h, uint256 uniqueUsers);
    event TokenAdded(address indexed tokenAddress, string symbol);
    event TokenMetricsUpdated(address indexed tokenAddress, uint256 price, uint256 volume24h, uint256 marketCap);
    event AggregatorAuthorized(address indexed aggregator);
    event AggregatorRevoked(address indexed aggregator);

     // Modifiers
    modifier onlyAuthorizedAggregator() {
        require(authorizedAggregators[msg.sender], "Not authorized aggregator");
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedAggregators[msg.sender] = true;
        emit AggregatorAuthorized(msg.sender);
    }

    // Protocol Management
    function addProtocol(address _protocolAddress, string memory _name) external onlyOwner {
        require(_protocolAddress != address(0), "Invalid protocol address");
        require(protocols[_protocolAddress].contractAddress == address(0), "Protocol already exists");

        protocols[_protocolAddress] = Protocol({
            name: _name,
            contractAddress: _protocolAddress,
            tvl: 0,
            volume24h: 0,
            uniqueUsers: 0,
            lastUpdated: block.timestamp
        });

        registeredProtocols.push(_protocolAddress);
        emit ProtocolAdded(_protocolAddress, _name);
    }

     function updateProtocolMetrics(
        address _protocolAddress,
        uint256 _tvl,
        uint256 _volume24h,
        uint256 _uniqueUsers
    ) external onlyAuthorizedAggregator whenNotPaused nonReentrant {
        require(protocols[_protocolAddress].contractAddress != address(0), "Protocol not registered");

        Protocol storage protocol = protocols[_protocolAddress];
        protocol.tvl = _tvl;
        protocol.volume24h = _volume24h;
        protocol.uniqueUsers = _uniqueUsers;
        protocol.lastUpdated = block.timestamp;

        emit ProtocolUpdated(_protocolAddress, _tvl, _volume24h, _uniqueUsers);
    }


}