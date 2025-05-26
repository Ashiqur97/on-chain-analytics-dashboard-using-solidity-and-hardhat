// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IAnalytics.sol";

/**
 * @title DataProvider
 * @dev Contract that provides data to the Analytics contract
 */
contract DataProvider {
    IAnalytics public analytics;
    
    /**
     * @dev Constructor that sets the Analytics contract address
     * @param _analytics Address of the Analytics contract
     */
    constructor(address _analytics) {
        require(_analytics != address(0), "Invalid analytics address");
        analytics = IAnalytics(_analytics);
    }
    
    /**
     * @dev Updates token data in the Analytics contract
     * @param token Address of the token to update
     * @param name Name of the token
     * @param price Current price of the token
     * @param volume 24h trading volume of the token
     * @param holders Number of token holders
     */
    function submitTokenData(
        address token,
        string memory name,
        uint256 price,
        uint256 volume,
        uint256 holders
    ) external {
        analytics.updateToken(token, name, price, volume, holders);
    }
    
    /**
     * @dev Updates protocol data in the Analytics contract
     * @param protocol Address of the protocol to update
     * @param name Name of the protocol
     * @param tvl Total value locked in the protocol
     * @param users Number of unique users in the protocol
     */
    function submitProtocolData(
        address protocol,
        string memory name,
        uint256 tvl,
        uint256 users
    ) external {
        analytics.updateProtocol(protocol, name, tvl, users);
    }
}
