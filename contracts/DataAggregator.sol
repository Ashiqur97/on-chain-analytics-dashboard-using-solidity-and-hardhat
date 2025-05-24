// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IAnalyticsRegistry.sol";
import "./Analytics.sol";

/**
 * @title DataAggregator
 * @dev Aggregates data from various sources and updates the analytics registry
 */
contract DataAggregator {
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    IAnalyticsRegistry public registry;
    mapping(address => uint256) public lastUpdateTime;
    mapping(address => uint256) public prices;
    uint256 public constant UPDATE_INTERVAL = 1 hours;

    event PriceUpdated(address indexed token, uint256 price);
    event MetricsUpdated(address indexed target, uint256 timestamp);
    event RegistryUpdated(address indexed newRegistry);

    /**
     * @dev Constructor that sets the registry address
     * @param _registry Address of the Analytics contract implementing IAnalyticsRegistry
     */
    constructor(address _registry) {
        require(_registry != address(0), "Invalid registry address");
        registry = IAnalyticsRegistry(_registry);
        owner = msg.sender;
    }

    /**
     * @dev Updates the registry address
     * @param _newRegistry Address of the new Analytics contract
     */
    function setRegistry(address _newRegistry) external onlyOwner {
        require(_newRegistry != address(0), "Invalid registry address");
        registry = IAnalyticsRegistry(_newRegistry);
        emit RegistryUpdated(_newRegistry);
    }

    /**
     * @dev Updates the price of a token
     * @param _token Address of the token to update price for
     * @param _price New price of the token
     */
    function updatePrice(address _token, uint256 _price) external onlyOwner {
        require(_token != address(0), "Invalid token address");
        prices[_token] = _price;
        emit PriceUpdated(_token, _price);
    }

    // Data Collection
    
    /**
     * @dev Updates token metrics in the registry
     * @param _tokenAddress Address of the token to update
     * @param _price Current price of the token
     * @param _volume24h 24h trading volume of the token
     * @param _marketCap Market cap of the token
     * @param _holders Number of token holders
     */
    function updateTokenMetrics(
        address _tokenAddress,
        uint256 _price,
        uint256 _volume24h,
        uint256 _marketCap,
        uint256 _holders
    ) external {
        _validateUpdate(_tokenAddress, lastUpdateTime[_tokenAddress]);
        
        // Update the price in local storage
        prices[_tokenAddress] = _price;
        
        // Update registry
        registry.updateTokenMetrics(
            _tokenAddress,
            _price,
            _volume24h,
            _marketCap,
            _holders
        );

        _updateTimestamp(_tokenAddress);
    }

    /**
     * @dev Updates protocol metrics in the registry
     * @param _protocolAddress Address of the protocol to update
     * @param _tvl Total value locked in the protocol
     * @param _volume24h 24h volume of the protocol
     * @param _uniqueUsers Number of unique users in the protocol
     */
    function updateProtocolMetrics(
        address _protocolAddress,
        uint256 _tvl,
        uint256 _volume24h,
        uint256 _uniqueUsers
    ) external {
        _validateUpdate(_protocolAddress, lastUpdateTime[_protocolAddress]);

        // Update registry
        registry.updateProtocolMetrics(
            _protocolAddress,
            _tvl,
            _volume24h,
            _uniqueUsers
        );

        _updateTimestamp(_protocolAddress);
    }

    /**
     * @dev Internal function to validate that the caller is authorized to update metrics
     * @param _target Address of the target (token or protocol)
     * @param _lastUpdateTime Last update timestamp for the target
     */
    function _validateUpdate(address _target, uint256 _lastUpdateTime) internal view {
        require(_target != address(0), "Invalid target address");
        require(block.timestamp >= _lastUpdateTime + UPDATE_INTERVAL, "Too soon to update");
    }
    
    /**
     * @dev Internal function to update the last update timestamp
     * @param _target Address of the target (token or protocol)
     * @return The current block timestamp
     */
    function _updateTimestamp(address _target) internal returns (uint256) {
        uint256 currentTime = block.timestamp;
        lastUpdateTime[_target] = currentTime;
        emit MetricsUpdated(_target, currentTime);
        return currentTime;
    }
}
