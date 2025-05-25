// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title EventTracker
 * @dev Tracks and stores important blockchain events for analytics
 */
contract EventTracker {
    address public owner;
    bool private locked;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }
    struct Event {
        bytes32 eventType;
        address source;
        uint256 timestamp;
        bytes data;
    }

    struct EventType {
        string name;
        bool isActive;
        uint256 eventCount;
    }

    // State variables
    mapping(bytes32 => EventType) public eventTypes;
    mapping(bytes32 => Event[]) public events;
    mapping(address => bool) public authorizedSources;
    
    uint256 public constant MAX_EVENTS_PER_TYPE = 1000;
    uint256 public constant MAX_DATA_SIZE = 1024;

    // Events
    event EventLogged(bytes32 indexed eventType, address indexed source, uint256 timestamp);
    event EventTypeAdded(bytes32 indexed eventTypeId, string name);
    event EventTypeUpdated(bytes32 indexed eventTypeId, bool isActive);
    event SourceAuthorized(address indexed source);
    event SourceRevoked(address indexed source);

  modifier onlyAuthorizedSource() {
        require(authorizedSources[msg.sender], "Not authorized source");
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedSources[msg.sender] = true;
        emit SourceAuthorized(msg.sender);
    }

}