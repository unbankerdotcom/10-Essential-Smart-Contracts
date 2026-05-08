# High-Quality Smart Contracts Collection

This repository contains a collection of 10 fully professional and high-quality Solidity smart contracts. These contracts are designed with modern Ethereum development best practices in mind, utilizing Solidity ^0.8.20, OpenZeppelin integrations, custom errors for gas optimization, comprehensive NatSpec documentation, and strict access controls.

## Contracts Overview

### 1. SimpleStorage.sol
A robust implementation of the classic Simple Storage contract.
* **Features:** Access control via OpenZeppelin's `Ownable`, custom error handling to prevent zero-value storage, and state-change events.
* **Use Case:** A foundational contract for securely storing parameters or configuration variables on-chain.

### 2. HelloWorld.sol (Updatable Message Board)
An advanced greeting contract.
* **Features:** Immutable deployer reference, zero-length string protection, and access control. 
* **Use Case:** Can be used as a simple on-chain status board or "motd" (Message of the Day) that only the admin can modify.

### 3. BasicToken.sol
A professional ERC-20 token implementation.
* **Features:** Extends OpenZeppelin's `ERC20`, `ERC20Burnable`, and `Ownable`. Implements a hardcapped maximum supply and strict minting access controls.
* **Use Case:** Launching a utility token, DAO governance token, or in-game currency with deflationary and inflationary mechanics controlled by an owner or multisig.

### 4. Voting.sol
A fully-featured DAO-style voting ballot.
* **Features:** Struct-based state management, vote delegation (with circular delegation protection), and weighted voting rights.
* **Use Case:** On-chain governance, allowing a committee to vote on proposals securely, including liquid democracy mechanisms via delegation.

### 5. PiggyBank.sol
A modern digital piggy bank without the deprecated `selfdestruct` opcode.
* **Features:** Utilizes `ReentrancyGuard`, strict `active` modifiers, and custom errors. Allows anyone to deposit but only the owner can "smash" and withdraw.
* **Use Case:** A savings contract, tip jar, or personal vault for accumulating funds until a specific withdrawal event.

### 6. CrowdFund.sol
An ERC-20 based decentralized crowdfunding platform.
* **Features:** Reentrancy protection via `ReentrancyGuard`, `SafeERC20` for token interactions, and strict timeline enforcement via block timestamps.
* **Use Case:** Raising funds (in stablecoins or other ERC20s) for projects, where contributors are guaranteed a refund if the funding goal is not met by the deadline.

### 7. Escrow.sol
A secure escrow arrangement between a buyer, a seller, and a trusted arbiter.
* **Features:** State machine logic using `enum`, reentrancy guards, and restricted role-based functions.
* **Use Case:** Trustless P2P commerce, freelance job payments, or high-value asset transfers requiring third-party mediation.

### 8. Lottery.sol (Commit-Reveal Pattern)
A fair, self-contained lottery contract resistant to miner/validator manipulation.
* **Features:** Implements a two-phase commit-reveal scheme to generate pseudorandomness safely without relying directly on `block.timestamp`.
* **Use Case:** Running provably fair on-chain raffles, giveaways, or randomized reward distributions without external oracle dependencies.

### 9. MultiSigWallet.sol
A robust multi-signature vault.
* **Features:** Transaction proposal, confirmation, and execution flows. Checks against duplicate owners, duplicate confirmations, and confirmation thresholds.
* **Use Case:** Securing treasury funds, managing protocol administrative roles, or collaborative asset management requiring M-of-N consensus.

### 10. TimeLock.sol
A governance timelock controller for executing arbitrary transactions.
* **Features:** Transaction queueing with minimum/maximum delay constraints, grace periods, and custom hash encoding. Includes `Ownable` for queueing permission.
* **Use Case:** Giving a community a transparent waiting period before protocol upgrades, administrative parameter changes, or large fund movements are executed.

## Development & Best Practices

All contracts are written enforcing standard security practices:
- **Custom Errors:** Used instead of string requires (e.g. `revert Unauthorized()`) to save significant gas during deployment and execution.
- **NatSpec Comments:** Developer and user-focused comments conform to the Ethereum Natural Specification Format.
- **CEI Pattern:** Functions adhere strictly to the Checks-Effects-Interactions pattern to prevent reentrancy attacks natively.
- **OpenZeppelin Contracts:** Heavy reliance on audited standard libraries (like `Ownable`, `ReentrancyGuard`, and `SafeERC20`).

## How to Deploy

### Option 1: Quick Deployment using Remix IDE (Recommended for Beginners/Testing)
The fastest way to test and deploy these contracts is through the browser-based [Remix IDE](https://remix.ethereum.org/).
1. Open Remix and create a new blank workspace.
2. Create a new file (e.g., `BasicToken.sol`) and paste the contract code inside.
3. On the left sidebar, click the **Solidity Compiler** tab (the standard 'S' icon). Make sure the compiler version matches `^0.8.20` and hit "Compile". (Note: Remix will automatically fetch the OpenZeppelin imports).
4. Go to the **Deploy & Run Transactions** tab.
5. In the "Environment" dropdown, select **Injected Provider - MetaMask** to connect your wallet (e.g., to the Base network, Sepolia testnet, etc.).
6. Expand the "Deploy" tab by clicking the small arrow next to it to reveal the constructor arguments. Fill them in properly:
   - For strings/addresses: Use standard text.
   - For arrays (like `bytes32[]` or `address[]`): Wrap them in brackets and quotes. Example: `["0xAddress1...", "0xAddress2..."]`
   - For numbers/amounts (like `uint256` token supplies): Remember to add 18 zeros for standard 18-decimal configurations. Example: `1000000000000000000000` for 1000 tokens.
7. Click **Transact** and confirm the transaction in your wallet.

### Option 2: Professional Deployment using Hardhat / Foundry
For production-grade deployment and testing, use a local development environment.
1. Initialize a new project (`npx hardhat` or `forge init`).
2. Install OpenZeppelin contracts (`npm install @openzeppelin/contracts` or `forge install OpenZeppelin/openzeppelin-contracts`).
3. Place these `.sol` files in your `/contracts` or `/src` directory.
4. Write deployment scripts in JS/TS (Hardhat) or Solidity (Foundry) passing the necessary constructor arguments.
5. Deploy to your network of choice via CLI commands.
