// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Analytics {
    address public owner;

    struct TokenData {
        string name;
        uint256 price;
        uint256 volume;
        uint256 holders;
        uint256 lastUpdate; 
    }

    struct ProtocolData {
        string name;
        uint256 tvl;
        uint256 users;
        uint256 lastUpdate;
    }

    //Storage
    mapping (address => TokenData) public tokens;
    mapping (address => ProtocolData) public protocols;
    mapping (address => bool) public dataProviders;


    //Events
    event TokenUpdated(address token, uint256 price, uint256 volume);
    event ProtocolUpdated(address protocol, uint256 tvl,uint256 users);
    event DataProviderAdded(address provider);
    event DataProviderRemoved(address provider);

    constructor () {
        owner = msg.sender;
        dataProviders[msg.sender] = true;
    }

      modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyDataProvider() {
        require(dataProviders[msg.sender], "Not authorized");
        _;
    }

    function removeDataProvider(address provider) external onlyOwner {
        dataProviders[provider] = false;
        emit DataProviderRemoved(provider);
    }

       // Data update functions
    function updateToken(
        address tokenAddress,
        string memory name,
        uint256 price,
        uint256 volume,
        uint256 holders
    ) external onlyDataProvider {
        tokens[tokenAddress] = TokenData(
            name,
            price,
            volume,
            holders,
            block.timestamp
        );
        emit TokenUpdated(tokenAddress, price, volume);
    }

    function updateProtocol(
        address protocolAddress,
        string memory name,
        uint256 tvl,
        uint256 users
    ) external onlyDataProvider {
        protocols[protocolAddress] = ProtocolData(name,
        tvl,
        users,
        block.timestamp
        );
        emit ProtocolUpdated(protocolAddress, tvl,users);
    }

    //view functions
    function getToken(address tokenAddress) external view returns (TokenData memory) {
        return tokens[tokenAddress];
    }

    function getProtocols(address protocolAddress) external view returns(ProtocolData memory) {
        return protocols[protocolAddress];
    }
    
}