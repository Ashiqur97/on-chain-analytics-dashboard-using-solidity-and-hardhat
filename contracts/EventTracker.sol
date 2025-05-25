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

    function addEventType(string calldata _name) external onlyOwner returns (bytes32) {
        bytes32 eventTypeId = keccak256(abi.encodePacked(_name));
        require(!eventTypes[eventTypeId].isActive, "Event type already exists");

        eventTypes[eventTypeId] = EventType({
            name: _name,
            isActive: true,
            eventCount:0
        });

        emit EventTypeAdded(eventTypeId, _name);
        return eventTypeId;
    }

         function setEventTypeStatus(bytes32 _eventTypeId, bool _isActive) external onlyOwner {
        require(bytes(eventTypes[_eventTypeId].name).length > 0, "Event type does not exist");
        eventTypes[_eventTypeId].isActive = _isActive;
        emit EventTypeUpdated(_eventTypeId, _isActive);
    }
    
        // Source Management
    function authorizeSource(address _source) external onlyOwner {
        require(_source != address(0), "Invalid source address");
        require(!authorizedSources[_source], "Source already authorized");
        
        authorizedSources[_source] = true;
        emit SourceAuthorized(_source);
    }

        function revokeSource(address _source) external onlyOwner {
        require(authorizedSources[_source], "Source not authorized");
        
        authorizedSources[_source] = false;
        emit SourceRevoked(_source);
    }

    
      function logEvent(
        bytes32 _eventType,
        bytes calldata _data
    ) external onlyAuthorizedSource nonReentrant {
        require(eventTypes[_eventType].isActive, "Event type not active");
        require(_data.length <= MAX_DATA_SIZE, "Data too large");
        require(eventTypes[_eventType].eventCount < MAX_EVENTS_PER_TYPE, "Event limit reached");

        Event memory newEvent = Event({
            eventType: _eventType,
            source: msg.sender,
            timestamp: block.timestamp,
            data: _data
        });

        events[_eventType].push(newEvent);
        eventTypes[_eventType].eventCount++;

        emit EventLogged(_eventType, msg.sender, block.timestamp);
    }

     // View Functions
    function getEventCount(bytes32 _eventType) external view returns (uint256) {
        return eventTypes[_eventType].eventCount;
    }

        function getEvents(
        bytes32 _eventType,
        uint256 _startIndex,
        uint256 _count
    ) external view returns (Event[] memory) {
        require(_startIndex < events[_eventType].length, "Start index out of bounds");
        
        uint256 endIndex = _startIndex + _count;
        if (endIndex > events[_eventType].length) {
            endIndex = events[_eventType].length;
        }
        
        Event[] memory result = new Event[](endIndex - _startIndex);
        for (uint256 i = _startIndex; i < endIndex; i++) {
            result[i - _startIndex] = events[_eventType][i];
        }
        
        return result;
    }

    function getEventType(bytes32 _eventTypeId) external view returns (
        string memory name,
        bool isActive,
        uint256 eventCount
    ) {
        EventType memory eventType = eventTypes[_eventTypeId];
        return (eventType.name, eventType.isActive, eventType.eventCount);
    }

}