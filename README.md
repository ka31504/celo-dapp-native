# CELO DApp Suite: Web3 Applications Using CELO as the Native Payment Token

## 1. Project Overview

**CELO DApp Suite** is a decentralized application (DApp) collection deployed on the **Celo Sepolia Testnet**, using **CELO** as the native payment token.  
The project demonstrates how to build and deploy Web3 economic models through smart contracts on an EVM-compatible blockchain.

The suite includes four main smart contracts:

| Application | Description |
|--------------|--------------|
| Play-to-Earn (P2E) | Players earn CELO rewards by achieving the target score |
| NFT Ticketing | Event tickets represented as ERC-721 NFTs, purchased with CELO |
| Creator Stream | Sponsors gradually stream CELO payments to content creators |
| Pay-per-View (PPV) | Viewers pay CELO to access limited-time premium content |

All contracts are written in **Solidity**, deployed, and tested directly using **Remix IDE** integrated with **MetaMask**.

---

## 2. Technologies Used

- Language: Solidity `^0.8.24`  
- Platform: Celo Sepolia Testnet  
- Wallet: MetaMask  
- Development Environment: Remix Ethereum IDE  
- Libraries: OpenZeppelin (Ownable, ERC721, ReentrancyGuard)

---

## 3. Project Structure

```
celo-dapp-native/
│
├── contracts/
│   ├── PlayToEarnNative.sol
│   ├── Ticketing721Native.sol
│   ├── CreatorStreamNative.sol
│   └── PayPerViewNative.sol
│
└── README.md
```

---

## 4. Configuring the Celo Sepolia Network in MetaMask

### Step 1. Add the network

```
Network Name: Celo Sepolia Testnet
RPC URL: https://forno.celo-sepolia.celo-testnet.org
Chain ID: 11142220
Currency Symbol: CELO
Block Explorer: https://celo-sepolia.blockscout.com
```

### Step 2. Get test CELO for gas and transactions

Access the official faucet:  
https://faucet.celo.org/celo-sepolia

---

## 5. Deploying Contracts (Manual – Remix IDE)

1. Open Remix IDE: https://remix.ethereum.org  
2. Connect MetaMask and select **Celo Sepolia Testnet**  
3. Go to the **Deploy & Run Transactions** tab  
4. Set Environment → **Injected Provider – MetaMask**  
5. Deploy each contract in this order:

### PlayToEarnNative
Constructor parameters:
```
rewardPerWin = 100000000000000000   // 0.1 CELO
minScore = 50
```
Click **Deploy** and confirm the transaction on MetaMask.

### Ticketing721Native
No constructor parameters.  
Click **Deploy** and confirm.

### CreatorStreamNative
No constructor parameters.  
Click **Deploy** and confirm.

### PayPerViewNative
No constructor parameters.  
Click **Deploy** and confirm.

After deployment, Remix displays contract addresses under **Deployed Contracts**.

---

## 6. Usage and Testing Guide

### 6.1 PlayToEarn (Earn CELO Rewards)
- `fund()`: deposit CELO rewards into the contract (set Value = 1 CELO in Remix)  
- `play(score)`: players input a score; if ≥ `minScore`, they receive CELO rewards  
- `setParams(newReward, newMinScore)`: adjust reward and difficulty settings  

Example:
- Call `fund()` with Value = 1 CELO  
- Then call `play(80)` → player with score ≥ 50 earns 0.1 CELO

---

### 6.2 NFT Ticketing (Event Tickets)
- `createEvent(name, priceWei, startTime, maxSupply, lock, baseURI, payout)`  
- `buy(eventId)`: purchase NFT tickets with CELO  

Example:
```
createEvent("Concert", 500000000000000000, 1736000000, 100, true, "ipfs://...", payoutAddress)
```
Buyer sets Value = 0.5 CELO → calls `buy(1)` → receives NFT ticket, CELO is transferred to the organizer’s wallet.

---

### 6.3 Creator Stream (Continuous Payment Streaming)
- `createStream(creator, start, end)`: sponsor deposits CELO to be streamed gradually  
- `withdraw(id, amount)`: creator withdraws the earned portion over time  

Example:
- Sponsor sends 3 CELO → `createStream(creator, now, now+30days)`  
- Creator calls `withdraw(1, 1000000000000000000)` to withdraw 1 CELO after several days.

---

### 6.4 Pay-per-View (Content Monetization)
- `upsertContent(contentId, priceWei, accessWindow, active)`: creator registers content  
- `buy(contentId)`: viewer pays CELO to access content  
- `hasAccess(contentId, viewer)`: check access validity  

Example:
```
upsertContent(keccak256("video#1"), 200000000000000000, 86400, true)
```
Viewer calls `buy(contentId)` with Value = 0.2 CELO → gains access for 24 hours.

---

## 7. Transaction Tracking

All transactions and events can be viewed at:  
https://celo-sepolia.blockscout.com  

Enter your wallet or contract address to review the history and logs.

---

## 8. Economic Model (Token Flow)

```
Player / Viewer → sends CELO → Smart Contract → Organizer / Creator receives CELO
```

All transactions are executed on-chain using CELO, ensuring transparency and verifiability.

---

## 9. Security and Scalability

- Contracts use `ReentrancyGuard` to prevent reentrancy attacks.  
- Only native **CELO** is used (no ERC-20 dependency).  
- Potential extensions:
  - Add `Pausable` or `AccessControl` for admin management.  
  - Build a web interface (React + ethers.js).  
  - Deploy the same contracts on **Celo Mainnet** after testing.

---

## 10. License

```
SPDX-License-Identifier: MIT
```

Open-source project — free for educational and research use.

---

## 11. Author

**Pham Quang Khai (ka31504)**  
Faculty of Information Technology – Phenikaa University  
GitHub: [https://github.com/ka31504](https://github.com/ka31504)  
LinkedIn: [https://linkedin.com/in/khaipham315](https://linkedin.com/in/khaipham315)

---
