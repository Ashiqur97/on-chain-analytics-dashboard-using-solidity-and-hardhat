pragma solidity ^0.8.19;

import "./interfaces/IAnalyticsRegistry.sol";

contract DataAggregator {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    IAnalyticsRegistry public registry;
    mapping (address => uint256) public lastUpdateTime;
    mapping (address => uint256) public prices;
    uint256 public constant UPDATE_INTERVAL = 1 hours;

    
    

}