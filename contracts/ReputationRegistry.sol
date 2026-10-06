// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAgentIdentityOwner {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract ReputationRegistry {
    struct Aggregate { uint64 total; uint64 count; }
    IAgentIdentityOwner public immutable identity;
    mapping(uint256 => Aggregate) public aggregates;
    mapping(bytes32 => bool) public usedReceipts;
    mapping(uint256 => mapping(address => bool)) public trustedReviewers;

    event ReviewerAuthorizationUpdated(uint256 indexed agentId, address indexed reviewer, bool authorized);
    event FeedbackGiven(uint256 indexed agentId, address indexed reviewer, uint8 score, bytes32 indexed receipt);

    constructor(address identityAddress) {
        require(identityAddress != address(0), "Zero identity");
        identity = IAgentIdentityOwner(identityAddress);
    }

    function setReviewer(uint256 agentId, address reviewer, bool authorized) external {
        require(identity.ownerOf(agentId) == msg.sender, "Not agent owner");
        require(reviewer != address(0), "Zero reviewer");
        trustedReviewers[agentId][reviewer] = authorized;
        emit ReviewerAuthorizationUpdated(agentId, reviewer, authorized);
    }

    function giveFeedback(uint256 agentId, uint8 score, bytes32 receipt) external {
        require(identity.ownerOf(agentId) != address(0), "Unknown agent");
        require(trustedReviewers[agentId][msg.sender], "Reviewer not authorized");
        require(score <= 100, "Invalid score");
        require(receipt != bytes32(0), "Empty receipt");
        require(!usedReceipts[receipt], "Receipt used");
        usedReceipts[receipt] = true;
        Aggregate storage aggregate = aggregates[agentId];
        aggregate.total += score;
        aggregate.count += 1;
        emit FeedbackGiven(agentId, msg.sender, score, receipt);
    }

    function scoreOf(uint256 agentId) external view returns (uint256) {
        Aggregate memory aggregate = aggregates[agentId];
        return aggregate.count == 0 ? 0 : aggregate.total / aggregate.count;
    }
}
