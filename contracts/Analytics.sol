// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IAnalyticsRegistry.sol";

contract Analytics is IAnalyticsRegistry {
    address public owner;
    
    struct TokenData {
        string name;
        uint256 price;
        uint256 volume;
        uint256 marketCap;
        uint256 holders;
        uint256 lastUpdate;
    }
    
    struct ProtocolData {
        string name;
        uint256 tvl;         // Total Value Locked
        uint256 users;       // Number of users
        uint256 lastUpdate;
    }
    
    // Storage
    mapping(address => TokenData) public tokens;
    mapping(address => ProtocolData) public protocols;
    mapping(address => bool) public dataProviders;
    
    // Track protocol metrics separately for IAnalyticsRegistry compatibility
    mapping(address => uint256) public protocolTVL;
    mapping(address => uint256) public protocolVolume24h;
    mapping(address => uint256) public protocolUniqueUsers;
    
    // Events
    event TokenUpdated(address token, uint256 price, uint256 volume, uint256 marketCap);
    event ProtocolUpdated(address protocol, uint256 tvl, uint256 users);
    event DataProviderAdded(address provider);
    event DataProviderRemoved(address provider);
    
    constructor() {
        owner = msg.sender;
        dataProviders[msg.sender] = true;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyDataProvider() {
        require(dataProviders[msg.sender], "Not authorized");
        _;
    }
    
    // IAnalyticsRegistry implementation
    function updateTokenMetrics(
        address _tokenAddress,
        uint256 _price,
        uint256 _volume24h,
        uint256 _marketCap,
        uint256 _holders
    ) external override onlyDataProvider {
        TokenData storage token = tokens[_tokenAddress];
        token.price = _price;
        token.volume = _volume24h;
        token.marketCap = _marketCap;
        token.holders = _holders;
        token.lastUpdate = block.timestamp;
        
        emit TokenUpdated(_tokenAddress, _price, _volume24h, _marketCap);
    }
    
    function updateProtocolMetrics(
        address _protocolAddress,
        uint256 _tvl,
        uint256 _volume24h,
        uint256 _uniqueUsers
    ) external override onlyDataProvider {
        ProtocolData storage protocol = protocols[_protocolAddress];
        protocol.tvl = _tvl;
        protocol.users = _uniqueUsers;
        protocol.lastUpdate = block.timestamp;
        
        // Update protocol metrics for IAnalyticsRegistry
        protocolTVL[_protocolAddress] = _tvl;
        protocolVolume24h[_protocolAddress] = _volume24h;
        protocolUniqueUsers[_protocolAddress] = _uniqueUsers;
        
        emit ProtocolUpdated(_protocolAddress, _tvl, _uniqueUsers);
    }

    // Management functions
    function addDataProvider(address provider) external onlyOwner {
        dataProviders[provider] = true;
        emit DataProviderAdded(provider);
    }
    
    function removeDataProvider(address provider) external onlyOwner {
        dataProviders[provider] = false;
        emit DataProviderRemoved(provider);
    }
    
    // Data update functions
    function updateToken(
        address tokenAddress,
        string memory name,
        uint256 price,
        uint256 volume,
        uint256 marketCap,
        uint256 holders
    ) external onlyDataProvider {
        tokens[tokenAddress] = TokenData(
            name,
            price,
            volume,
            marketCap,
            holders,
            block.timestamp
        );
        emit TokenUpdated(tokenAddress, price, volume, marketCap);
    }
    
    function updateProtocol(
        address protocolAddress,
        string memory name,
        uint256 tvl,
        uint256 users
    ) external onlyDataProvider {
        protocols[protocolAddress] = ProtocolData(
            name,
            tvl,
            users,
            block.timestamp
        );
        emit ProtocolUpdated(protocolAddress, tvl, users);
    }
    
    // View functions
    function getToken(address tokenAddress) external view returns (TokenData memory) {
        return tokens[tokenAddress];
    }
    
    function getProtocol(address protocolAddress) external view returns (ProtocolData memory) {
        return protocols[protocolAddress];
    }
}
