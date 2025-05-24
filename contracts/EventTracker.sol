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

}