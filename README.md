# AV Agent Hub

## Overview

AV Agent Hub is a wallet-connected platform built around three core parts: AI Agent Management, AI Agent Audit, and AI Agent Service Marketplace. It enables registering AI-agent identities, publishing services, building on-chain reputation, and making test payments on Avalanche Fuji. It combines four trust layers: NFT identity, service marketplace, authorized reputation, and direct AVAX or ERC-20/USDC payments.

The project was started from scratch during the hackathon. The current release is a Fuji testnet implementation. The team intends to develop on mainnet and expand the platform into a practical solution for agent management, agent audit, and agent service marketplace.

## Why This Matters

Agent management today is fragmented. Agents are created in different frameworks, registered in different directories, and identified by API keys or platform accounts. There is no portable ownership record, no common service registry, and no clear way to authorize or revoke reviewers. Agent audit is even weaker. Most systems cannot prove who operated an agent, what service was purchased, what payment was made, or whether a review is legitimate. Logs are often off-chain, mutable, and scattered.

AV Agent Hub addresses these pain points with on-chain identity, service records, authorized reviewer controls, unique receipt references, and payment references that can be verified on Snowtrace. The Fuji release tests these primitives. The mainnet direction is to make them production-ready for teams that need verifiable agent management and audit trails. The platform is organized into three parts: AI Agent Management, AI Agent Audit, and AI Agent Service Marketplace. Payments are the mechanism that lets users and agents pay for services using AVAX or USDC.

## Target Users and Market

Primary users are AI-agent developers, service providers, agent NFT owners, authorized reviewers, and platform builders. Secondary users include researchers, compliance teams, and early adopters exploring decentralized agent infrastructure.

The target market is Web3 AI-agent infrastructure, decentralized identity, agent marketplaces, on-chain reputation, and audit tooling. The value is a verifiable, wallet-based record of agent ownership, service publication, reputation, and payments. The potential is a shared trust layer that other agent frameworks, marketplaces, and payment systems can integrate with.

## How It Works Under the Hood

AV Agent Hub is a browser-based dApp connected to Avalanche Fuji (Chain ID 43113), and will change to mainnet for the next phase. It uses an injected EIP-1193 wallet such as MetaMask and an HTTPS RPC endpoint configured through frontend environment variables.

The platform has three parts. AI Agent Management covers identity, ownership, access level, and metadata. AI Agent Audit covers reputation, reviewer authorization, receipt references, and payment references that can be checked on-chain. AI Agent Service Marketplace covers service publishing, pricing, metadata, and discovery. Payments are the mechanism that lets users and agents pay for agent services with AVAX or USDC. The current testnet implementation supports direct AVAX transfers and ERC-20/USDC payments via approve and transferFrom. Future development will expand this into a production payment rail for agent service consumption.

The four trust layers are implemented by deployed smart contracts. Agent and service details are stored in off-chain metadata URIs while minimal records remain on-chain. The Identity Registry records Agent ID, NFT owner, metadata URI, and access level. The Marketplace stores service ID, active status, provider address, test AVAX price, and metadata URI. The Reputation Registry uses owner-controlled setReviewer authorization, trustedReviewers(agentId, reviewer) checks, 0 to 100 scores, and one-time receipt hashes. Payments are direct, non-gasless AVAX transfers or ERC-20/USDC payments via approve and transferFrom. Reference strings are UTF-8 encoded, Keccak-256 hashed to bytes32, and used to link payments and reviews.

Integrations include MetaMask, Avalanche Fuji RPC, Snowtrace for transaction evidence, IPFS or HTTPS for metadata, ERC-20 token contracts, and Hardhat or block-explorer write interfaces for owner-only actions not exposed in the UI.

## User Tutorial

### 1. Sign In with a Wallet

1. Open AV Agent Hub.
2. Find Sign in with wallet in the top navigation.
3. Click the button.
4. Approve the connection in MetaMask.
5. If the wallet is on another network, click Switch to Avalanche Fuji.
6. Approve the network switch.
7. When connected successfully, the button displays a shortened wallet address and Fuji.

Signing in does not require a blockchain transaction. Registering an identity, registering a service, submitting reputation, approving USDC, and making payments do require transactions. The wallet must have Fuji AVAX to pay transaction fees. Write buttons remain disabled if the wallet is disconnected or on the wrong network.

### 2. Home Page

The Home page provides a platform overview and deployment status. It shows the Avalanche Fuji chain ID, available on-chain workflows, whether the required public configuration is complete, and a Connect and register button that opens the Agents page. The button does not automatically connect a wallet. After entering the Agents page, use Sign in with wallet in the navigation.

### 3. Agents Page

The Agents page registers and lists AI-agent identities on Avalanche Fuji. An Agent identity contains Agent ID, NFT owner, metadata URI, and access level. The name, description, service list, endpoint, and other detailed information should be stored in the external metadata document referenced by the URI. This page is part of AI Agent Management.

How to register an Agent:

1. Connect your wallet.
2. Switch to Avalanche Fuji.
3. Open Agents.
4. Enter a Metadata URI, for example https://bafy.../agent.json.
5. Enter an Access level from 0 to 255.
6. Click Register on Fuji.
7. Confirm the transaction in your wallet.
8. Wait for the confirmation message.
9. Open the Snowtrace link to inspect the transaction.
10. Click Refresh to reload the identity list.

The page displays up to the most recent 20 identities. A practical metadata document can look like this:

```json
{
  "name": "Example Agent",
  "description": "An agent that summarizes technical documents.",
  "services": [
    {
      "name": "Document Summary",
      "endpoint": "https://agent.example.com/summarize"
    }
  ],
  "provider": {
    "name": "Example Provider",
    "contact": "security@example.com"
  }
}
```

Do not place private keys, API secrets, personal information, or confidential prompts in public metadata. The contract supports updating the metadata URI and access level, but the current Agents page does not provide those controls. Contract interaction tools are required for those operations.

### 4. Marketplace Page

The Marketplace page allows providers to publish services and allows users to inspect services registered on Fuji. This page is the AI Agent Service Marketplace. Each service contains Service ID, active or inactive status, provider wallet address, test AVAX price, and metadata URI.

How to register a service:

1. Connect the provider wallet.
2. Switch to Avalanche Fuji.
3. Open Marketplace.
4. Enter the Test AVAX price, for example 0.01.
5. Enter the Service metadata URI, for example https://example.com/services/summary-service.json.
6. Click Register service.
7. Confirm the transaction.
8. Wait for block confirmation.
9. Click Refresh to reload the marketplace.

The interface does not yet provide keyword search, price filtering, reputation ranking, service editing, or service activation and deactivation controls. The contract allows the original provider to update a service, but the current page does not expose that action.

### 5. Reputation Page

The Reputation page allows an authorized Reviewer to submit a score for an Agent and allows any user to read the Agent's aggregate score. This page is part of AI Agent Audit. Scores range from 0 to 100. Only an authorized Reviewer can submit feedback. Authorization is specific to an Agent ID and wallet address. Each receipt hash can be used only once globally. The displayed aggregate uses integer division, so decimal values may be truncated.

### 6. How to Add a Reviewer

The current Reputation page does not include a Reviewer-management form. The Agent NFT owner must authorize the Reviewer through a contract interaction tool, block explorer, or custom script. Only the current owner of the Agent NFT can call:

```solidity
setReviewer(uint256 agentId, address reviewer, bool authorized)
```

Method A: Use a block explorer contract interface.

1. Obtain the deployed ReputationRegistry contract address.
2. Open the contract on a Fuji-compatible block explorer.
3. Confirm that the contract address and verified source match your deployment.
4. Connect the wallet that owns the Agent NFT.
5. Open the contract's write interface.
6. Find setReviewer(uint256 agentId, address reviewer, bool authorized).
7. Enter the Agent ID, Reviewer address, and true.
8. Submit the transaction.
9. Confirm it in the owner wallet.
10. Wait for the ReviewerAuthorizationUpdated event.
11. Read trustedReviewers(agentId, reviewer).
12. Confirm that the returned value is true.

Method B: Use a Hardhat script.

```javascript
const reputation = await ethers.getContractAt(
  "ReputationRegistry",
  process.env.REPUTATION_REGISTRY_ADDRESS
);

const tx = await reputation.setReviewer(
  AGENT_ID,
  REVIEWER_ADDRESS,
  true
);

await tx.wait();
```

The script must run with the Agent owner's private key. Never commit that private key. To revoke a Reviewer, use the same function with authorized: false.

Reviewer safety notes: only authorize wallets you trust, use a dedicated Reviewer wallet, review authorization after transferring an Agent NFT, remember that old Reviewer authorizations are not automatically removed when ownership changes, and note that authorization for one Agent does not authorize reviews for another Agent.

### 7. How an Authorized Reviewer Submits Feedback

1. Connect the exact wallet address authorized as the Reviewer.
2. Switch to Avalanche Fuji.
3. Open Reputation.
4. Enter the Agent ID.
5. Enter a score from 0 to 100.
6. Enter a unique Receipt reference.
7. Click Write feedback.
8. Confirm the transaction.
9. Wait for block confirmation.
10. Enter the Agent ID in the score lookup section.
11. Click Refresh score.

If the transaction returns Reviewer not authorized, verify that the connected wallet is the authorized address, that the authorization belongs to the same Agent ID, and that trustedReviewers(agentID, reviewer) returns true.

### 8. Payment Reference and Receipt Reference

Both payment and reputation forms accept a readable reference string. The browser converts the string to UTF-8 and hashes it with Keccak-256 before sending a bytes32 value on-chain. A recommended format is:

```text
fuji:<transaction-hash>:<agent-id>
```

or:

```text
order-2026-000123
```

To associate a review with a payment, enter exactly the same reference text in the Payment reference on the Payments page and the Receipt reference on the Reputation page. The text is case-sensitive, and spaces and punctuation also matter.

Do not include private keys, API secrets, personal information, or confidential order details. A Reputation receipt hash can only be used once. The payment contracts do not enforce reference uniqueness, so users must manage references carefully.

### 9. Payments Page

The Payments page is being developed to let users and agents pay for agent services using AVAX or USDC. The current Fuji testnet implementation provides two direct payment methods: native AVAX, and configured ERC-20/USDC using approve and transferFrom. These payments do not use an x402 facilitator and are not gasless. Future development will expand this into a production payment rail for agent service consumption.

Pay with AVAX:

1. Connect the payer wallet.
2. Switch to Fuji.
3. Open Payments.
4. In the AVAX section, enter the recipient address.
5. Enter the AVAX amount.
6. Enter a unique payment reference.
7. Click Pay AVAX.
8. Confirm the transaction.
9. Wait for confirmation.
10. Open the Snowtrace transaction link.

The contract sends the AVAX directly to the recipient. It rejects zero recipient address, paying yourself, zero amount, empty reference, and a recipient contract that refuses AVAX.

Pay with USDC or the configured token:

1. Confirm that the token address displayed by the deployment is independently verified.
2. Make sure your wallet holds the configured token and Fuji AVAX.
3. Enter the recipient address.
4. Enter the token amount.
5. Enter a unique payment reference.
6. Click 1. Approve exact amount.
7. Confirm the approval transaction.
8. Wait until the allowance is updated.
9. Click 2. Pay confirmed allowance.
10. Confirm the payment transaction.
11. Wait for confirmation and inspect the Snowtrace link.

The approval and payment are two separate transactions, so each normally requires Fuji AVAX for gas. The deployment script can confirm that the configured token address contains contract code, exposes ERC-20 metadata, and returns a symbol, decimals, and total supply. However, these checks do not prove that the token is officially issued by Circle. The deployer must independently confirm the current Fuji USDC address using authoritative issuer and network information.

### 10. Security Page

The Security page is an informational page describing the intended security baseline. It references practices such as NIST AI Risk Management Framework, ISO/IEC 42001, OWASP guidance for LLM and agent applications, zero-trust authorization, spending limits, transaction simulation, facilitator allowlisting, and EIP-712 and EIP-3009 design.

Not every item displayed on the Security page is currently enforced by the direct AVAX and token-payment implementation. The current direct payment path does not yet implement x402 facilitator settlement, EIP-712 payment signatures, EIP-3009 token authorization, EIP-7702 gas sponsorship, automatic transaction simulation, runtime daily-budget enforcement, or batch settlement. Treat this page as a security baseline and roadmap, not as an independent security certification.

## Recommended Complete User Journey

A practical end-to-end workflow is:

1. Connect the wallet.
2. Switch to Avalanche Fuji.
3. Register an Agent identity.
4. Save the new Agent ID.
5. Register the Agent's service in Marketplace.
6. Ask the Agent NFT owner to authorize a Reviewer through the Reputation Registry contract.
7. Create a unique, non-sensitive payment reference.
8. Pay the provider using AVAX or approved USDC.
9. Save the payment transaction hash and reference.
10. Ask the authorized Reviewer to connect the authorized wallet.
11. Submit a score using the same reference.
12. Refresh the aggregate score.
13. Verify transactions and events on Snowtrace.

## Common Errors

Identity registry is not configured: Identity address is missing from the frontend build. Set the correct public address and restart or redeploy. Marketplace contract is not configured: Marketplace address is missing. Configure the deployed address. Reputation address is missing: Configure the deployed address. Switch to Avalanche Fuji: Wallet is on the wrong network. Approve the network switch. Not agent owner: The caller does not own the Agent NFT. Use the current owner wallet. Zero reviewer: Reviewer address is the zero address. Enter a valid wallet address. Reviewer not authorized: The connected reviewer wallet lacks permission. Ask the owner to call setReviewer. Invalid score: Score is above 100. Enter a value from 0 to 100. Empty receipt: Receipt hash is empty. Enter a non-empty unique reference. Receipt used: The receipt was already submitted. Use a new valid receipt reference. Not provider: The caller did not register the service. Use the original provider wallet. Insufficient allowance: USDC approval is too low. Approve the exact amount first. Insufficient balance: Wallet lacks AVAX or token balance. Fund the Fuji test wallet. User rejected transaction: Wallet confirmation was rejected. Submit again and approve. HTTP 501 from quote/payment API: x402 settlement is intentionally unavailable. Use the direct AVAX or token-payment interface.

## Current Platform Boundaries

Available after deployment and configuration: wallet login, Fuji network switching, agent identity registration and reading, service registration and reading, reputation score reading, authorized Reviewer feedback, direct AVAX payment, direct approved ERC-20/USDC payment, and transaction confirmation with Snowtrace links.

Requires an external contract tool: adding or revoking a Reviewer, updating Agent metadata or access level, and updating service information or active status.

## How It Compares

The AI agent infrastructure space is crowded, but most solutions are built on other chains or are chain-agnostic frameworks. AV Agent Hub is different because it is being built specifically for the Avalanche ecosystem, with the goal of becoming a production platform for AI agent management, AI agent audit, and AI agent service marketplace. It is currently deployed on Fuji testnet, but the roadmap leads to Avalanche mainnet. That positioning matters when comparing it to other tools.

Fetch.ai runs Agentverse on its own Cosmos chain. It offers cloud hosting, an IDE, and a large agent marketplace. It is a full-stack ecosystem with its own token and consensus. AV Agent Hub does not try to replicate that. It focuses on three parts that map directly to agent management, audit, and service marketplace: NFT identity, service registry, authorized reputation, and direct payments. It does not host agents or run a chain. It builds on Avalanche, which already provides fast finality, low fees, and a growing subnet ecosystem. For teams already in Avalanche, AV Agent Hub is a native fit. For teams that want a managed cloud and a large existing marketplace, Fetch.ai remains a stronger choice.

SingularityNET runs an AI marketplace on Ethereum with off-chain ratings and a curation layer. It has a live marketplace and legal agreements protecting users. AV Agent Hub puts reputation on-chain from the start, with reviewer authorization bound to specific agent IDs and wallet addresses. It also records payment references that can be linked to reviews for audit. The trade-off is maturity. SingularityNET has years of operation. AV Agent Hub is earlier but is designed for Avalanche and for auditability, which SingularityNET does not prioritize in the same way.

Olas runs the Mech Marketplace with millions of agent transactions and a consumer app called Pearl. It has a live agent economy with staking and co-ownership. AV Agent Hub does not have an agent-to-agent transaction layer or a consumer app. Its scope is narrower: identity, service publishing, authorized reputation, and direct payments with audit trails. It is not competing with Olas on transaction volume. It is building the management and audit layer that Olas and similar platforms could eventually integrate with, especially on Avalanche.

The honest positioning is this. AV Agent Hub is not trying to be everything to everyone. It is building an Avalanche-native platform for AI agent management, AI agent audit, and AI agent service marketplace. It is currently on Fuji testnet, but the goal is mainnet and real ecosystem adoption. It competes on ecosystem fit, low fees, fast finality, and a specific focus on auditability. It does not yet match the scale of Fetch.ai or Olas, but it is designed to solve problems those platforms do not fully address: portable agent identity, authorized reviewer controls, payment and receipt references for audit, and a clear path to production on Avalanche. For teams building agents on Avalanche, it aims to be the default management and audit layer.

## Summary

AV Agent Hub is a Fuji testnet implementation today, but its target is Avalanche mainnet. The project was started from scratch during the hackathon and is not a fork or a wrapper around an existing codebase. The goal is to land in the Avalanche ecosystem as a production platform for AI agent management, AI agent audit, and AI agent service marketplace. It provides on-chain identity through NFTs, a service marketplace with pricing and metadata, authorized reputation with unique receipt references, and direct AVAX or ERC-20/USDC payments that can be verified on Snowtrace. These primitives give developers and platform builders a way to register agents, publish services, collect authorized reviews, and create auditable payment trails. The current interface has limitations. Reviewer management, service editing, and agent metadata updates require external contract tools. x402, gasless transactions, automated settlement, automatic feedback, and marketplace search are not yet available. Mainnet deployment will require security audits, verified token addresses, production payment rails, and a reviewer management UI. But the direction is clear. AV Agent Hub is not just a testnet sandbox. It is an Avalanche-native trust layer for agent management, agent audit, and agent service marketplace, built to solve the fragmentation and accountability problems that currently hold back the agent economy. The platform already provides useful on-chain primitives, and the roadmap turns them into a production-grade solution on Avalanche.

## Update
### 20261006
* publish 1.0 version