// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAnalytics {
    function updateToken(
        address tokenAddress,
        string memory name,
        uint256 price,
        uint256 volume,
        uint256 marketCap,
        uint256 holders
    ) external;
    
    function updateProtocol(
        address protocolAddress,
        string memory name,
        uint256 tvl,
        uint256 users
    ) external;
}
