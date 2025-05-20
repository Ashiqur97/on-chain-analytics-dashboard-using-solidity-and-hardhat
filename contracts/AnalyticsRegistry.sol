// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


contract AnalyticsRegistry {
    address public owner;
    bool public paused;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused.");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    bool private locked;


    struct Protocol {
        string name;
        address contractAddress;
        uint256 tvl;
        uint256 volume24h;
        uint256 uinqueUsers;
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

    
}