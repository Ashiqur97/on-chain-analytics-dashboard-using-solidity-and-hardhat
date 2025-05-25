// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PriceOracle {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }
    
}