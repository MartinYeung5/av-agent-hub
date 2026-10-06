// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ServiceMarketplace {
    struct Service { address provider; uint256 priceWei; string uri; bool active; }
    uint256 public nextServiceId = 1;
    mapping(uint256 => Service) public services;

    event ServiceRegistered(uint256 indexed serviceId, address indexed provider, uint256 priceWei, string uri);
    event ServiceUpdated(uint256 indexed serviceId, uint256 priceWei, string uri, bool active);

    modifier onlyProvider(uint256 id) {
        require(services[id].provider == msg.sender, "Not provider");
        _;
    }

    function registerService(uint256 priceWei, string calldata uri) external returns (uint256 id) {
        require(priceWei > 0 && bytes(uri).length > 0, "Invalid service");
        id = nextServiceId++;
        services[id] = Service(msg.sender, priceWei, uri, true);
        emit ServiceRegistered(id, msg.sender, priceWei, uri);
    }

    function updateService(uint256 id, uint256 priceWei, string calldata uri, bool active) external onlyProvider(id) {
        require(priceWei > 0 && bytes(uri).length > 0, "Invalid service");
        Service storage service = services[id];
        service.priceWei = priceWei;
        service.uri = uri;
        service.active = active;
        emit ServiceUpdated(id, priceWei, uri, active);
    }
}
