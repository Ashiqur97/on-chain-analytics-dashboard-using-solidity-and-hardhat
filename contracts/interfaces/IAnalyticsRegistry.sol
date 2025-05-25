// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAnalyticsRegistry {
    function updateProtocolMetrics(
        address _protocolAddress,
        uint256 _tvl,
        uint256 _volume24h,
        uint256 _uniqueUsers
    ) external;

    function updateTokenMetrics(
        address _tokenAddress,
        uint256 _price,
        uint256 _volume24h,
        uint256 _marketCap,
        uint256 _holders
    ) external;
}
