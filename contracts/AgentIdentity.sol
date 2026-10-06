// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract AgentIdentity is ERC721URIStorage {
    uint256 public nextAgentId = 1;
    mapping(uint256 => uint8) public accessLevel;

    event AgentRegistered(uint256 indexed agentId, address indexed owner, string uri, uint8 accessLevel);
    event AgentURIUpdated(uint256 indexed agentId, string uri);
    event AccessLevelUpdated(uint256 indexed agentId, uint8 accessLevel);

    constructor() ERC721("AV Agent Identity", "AVAI") {}

    modifier onlyTokenOwner(uint256 id) {
        require(ownerOf(id) == msg.sender, "Not token owner");
        _;
    }

    function register(string calldata uri, uint8 level) external returns (uint256 id) {
        require(bytes(uri).length > 0, "Empty URI");
        id = nextAgentId++;
        _safeMint(msg.sender, id);
        _setTokenURI(id, uri);
        accessLevel[id] = level;
        emit AgentRegistered(id, msg.sender, uri, level);
    }

    function setAgentURI(uint256 id, string calldata uri) external onlyTokenOwner(id) {
        require(bytes(uri).length > 0, "Empty URI");
        _setTokenURI(id, uri);
        emit AgentURIUpdated(id, uri);
    }

    function setAccessLevel(uint256 id, uint8 level) external onlyTokenOwner(id) {
        accessLevel[id] = level;
        emit AccessLevelUpdated(id, level);
    }
}
