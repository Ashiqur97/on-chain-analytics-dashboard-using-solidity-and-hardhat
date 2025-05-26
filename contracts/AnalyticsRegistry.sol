// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AnalyticsRegistry
 * @dev Main registry contract for analytics data collection and management
 */
contract AnalyticsRegistry {
    address public owner;
    bool public paused;
    
    // Reentrancy guard
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status = _NOT_ENTERED;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract paused");
        _;
    }
    
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
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

    // Token Management
    function addToken(address _tokenAddress, string memory _symbol) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid token address");
        require(bytes(tokens[_tokenAddress].symbol).length == 0, "Token already exists");

        tokens[_tokenAddress] = TokenMetrics({
            symbol: _symbol,
            price: 0,
            volume24h: 0,
            marketCap: 0,
            holders: 0,
            lastUpdated: block.timestamp
        });

        registeredTokens.push(_tokenAddress);
        emit TokenAdded(_tokenAddress, _symbol);
    }

    function updateTokenMetrics(
        address _tokenAddress,
        uint256 _price,
        uint256 _volume24h,
        uint256 _marketCap,
        uint256 _holders
    ) external onlyAuthorizedAggregator whenNotPaused nonReentrant {
        require(bytes(tokens[_tokenAddress].symbol).length > 0, "Token not registered");

        TokenMetrics storage token = tokens[_tokenAddress];
        token.price = _price;
        token.volume24h = _volume24h;
        token.marketCap = _marketCap;
        token.holders = _holders;
        token.lastUpdated = block.timestamp;

        emit TokenMetricsUpdated(_tokenAddress, _price, _volume24h, _marketCap);
    }

    // Aggregator Management
    function authorizeAggregator(address _aggregator) external onlyOwner {
        require(_aggregator != address(0), "Invalid aggregator address");
        require(!authorizedAggregators[_aggregator], "Already authorized");
        
        authorizedAggregators[_aggregator] = true;
        emit AggregatorAuthorized(_aggregator);
    }

    function revokeAggregator(address _aggregator) external onlyOwner {
        require(authorizedAggregators[_aggregator], "Not authorized");
        
        authorizedAggregators[_aggregator] = false;
        emit AggregatorRevoked(_aggregator);
    }

    // View Functions
    function getProtocolCount() external view returns (uint256) {
        return registeredProtocols.length;
    }

    function getTokenCount() external view returns (uint256) {
        return registeredTokens.length;
    }

    function getProtocolMetrics(address _protocolAddress) 
        external 
        view 
        returns (
            string memory name,
            uint256 tvl,
            uint256 volume24h,
            uint256 uniqueUsers,
            uint256 lastUpdated
        ) 
    {
        Protocol memory protocol = protocols[_protocolAddress];
        return (
            protocol.name,
            protocol.tvl,
            protocol.volume24h,
            protocol.uniqueUsers,
            protocol.lastUpdated
        );
    }

    function getTokenMetrics(address _tokenAddress)
        external
        view
        returns (
            string memory symbol,
            uint256 price,
            uint256 volume24h,
            uint256 marketCap,
            uint256 holders,
            uint256 lastUpdated
        )
    {
        TokenMetrics memory token = tokens[_tokenAddress];
        return (
            token.symbol,
            token.price,
            token.volume24h,
            token.marketCap,
            token.holders,
            token.lastUpdated
        );
    }

    // Emergency Functions
    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }
}
