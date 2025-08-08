# ZKBridgeToken

**ZKBridgeToken** is an **omnichain ERC-20 token** integrated with **Polyhedra zkBridge** for secure cross-chain transfers.
It is deployed to the **same address** across multiple chains using **CREATE2**, with **initial token minting configured per chain** via a `ChainConfig` array.

Cross-chain transfers are handled by **burning tokens on the source chain** and **minting on the destination chain** via zkBridge.

---

## Features

* **Omnichain Deployment** – Same contract address across all supported chains using `CREATE2`.
* **Polyhedra zkBridge Integration** – Secure cross-chain transfers with zero-knowledge proofs.
* **Configurable Minting** – Initial token supply per chain defined in constructor via `ChainConfig`:

  ```solidity
  struct ChainConfig {
      uint256 evmChainId;
      uint256 mintAmount;
      uint16 zkBridgeChainId;
  }
  ```
* **Security** – Restricts `zkReceive` to mapped chains and validates same-address deployment.
* **Built with Foundry** – Deployment scripts, tests, and config via `foundry.toml`.

---

## Repository Structure

```
src/ZKBridgeToken.sol               # Main token contract (ERC-20 + zkBridge integration)
src/interfaces/IZKBridge.sol        # zkBridge send interface
src/interfaces/IZKBridgeReceiver.sol# zkBridge receive interface
script/Deploy.s.sol                 # Deployment script (CREATE2)
test/ZKBridgeToken.t.sol             # Tests for minting, bridging, edge cases
foundry.toml                         # Config with RPC endpoints
```

---

## Prerequisites

* [Foundry](https://book.getfoundry.sh/) (`forge`, `cast`)
* Git
* Environment variables for private key (`DEPLOYER_KEY`) and RPC endpoints (defined in `foundry.toml`)
* Node.js (optional, for extra scripts)
* Block explorer accounts for verification (Etherscan, BscScan, etc.)

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/liqueth/ZKBridgeToken.git
cd ZKBridgeToken
```

### 2. Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 3. Configure `foundry.toml`

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.30"

[rpc_endpoints]
sepolia       = "${SEPOLIA_RPC}"
bsc_testnet   = "${BSC_TESTNET_RPC}"
expchain_test = "${EXPCHAIN_TESTNET_RPC}"
```

### 4. Set environment variables

```bash
export SEPOLIA_RPC=<SEPOLIA_RPC_URL>
export BSC_TESTNET_RPC=<BSC_TESTNET_RPC_URL>
export EXPCHAIN_TESTNET_RPC=<EXPCHAIN_TESTNET_RPC_URL>
export DEPLOYER_KEY=<YOUR_PRIVATE_KEY>
```

### 5. Install dependencies

```bash
forge install OpenZeppelin/openzeppelin-contracts
```

Ensure `remappings.txt` contains:

```
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
```

### 6. Compile

```bash
forge build
```

---

## Deployment

**Mint configuration per chain:**

| Chain         | EVM Chain ID | zkBridge Chain ID | Mint Amount (ZBT) | zkBridge Address |
| ------------- | ------------ | ----------------- | ----------------- | ---------------- |
| Sepolia       | 11155111     | 119               | 3,000,000         | 0xa8a4…1C7       |
| BSC Testnet   | 97           | 103               | 2,000,000         | 0xa8a4…1C7       |
| EXPchain Test | 18880        | 131               | 1,000,000         | 0xa8a4…1C7       |

**Salt:**

```solidity
uint256 constant SALT = 1234; // Use same salt across all chains
```

---

### Deploy using script

```bash
# Sepolia
CONFIG=config/testnet.json \
forge script script/Deploy.s.sol \
  --rpc-url eth_test \
  --private-key $DEPLOYER_KEY \
  --broadcast

# BSC Testnet
CONFIG=config/testnet.json \
forge script script/Deploy.s.sol \
  --rpc-url bsc_test \
  --private-key $DEPLOYER_KEY \
  --broadcast

# EXPchain Testnet
CONFIG=config/testnet.json \
forge script script/Deploy.s.sol \
  --rpc-url exp_test \
  --private-key $DEPLOYER_KEY \
  --broadcast
```

---

### Deploy using `forge create`

**1. Encode constructor arguments**

```bash
cast abi-encode \
  "constructor(string,string,address,address,(uint256,uint16,uint256)[])" \
  "ZKBridgeToken" \
  "ZBT" \
  "0x129b0628A241e26D5048224c5B788E2D89CE6c40" \
  "0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7" \
  "[(11155111,119,3000000000000000000000000),(97,103,2000000000000000000000000),(18880,131,1000000000000000000000000)]"
```

**2. Deploy**

```bash
forge create src/ZKBridgeToken.sol:ZKBridgeToken \
  --rpc-url sepolia \
  --private-key $DEPLOYER_KEY \
  --constructor-args <ENCODED_ARGS> \
  --create2-salt 1234
```

---

## Verification

### Sepolia

```bash
forge verify-contract \
  --chain-id 11155111 \
  --constructor-args $(cast abi-encode "constructor(string,string,address,address,(uint256,uint16,uint256)[])" \
    "ZKBridgeToken" \
    "ZBT" \
    "0x129b0628A241e26D5048224c5B788E2D89CE6c40" \
    "0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7" \
    "[(11155111,119,3000000000000000000000000),(97,103,2000000000000000000000000),(18880,131,1000000000000000000000000)]") \
  <CONTRACT_ADDRESS> \
  src/ZKBridgeToken.sol:ZKBridgeToken \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### BSC Testnet

```bash
forge verify-contract \
  --chain-id 97 \
  --constructor-args $(cast abi-encode "constructor(string,string,address,address,(uint256,uint16,uint256)[])" \
    "ZKBridgeToken" \
    "ZBT" \
    "0x129b0628A241e26D5048224c5B788E2D89CE6c40" \
    "0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7" \
    "[(11155111,119,3000000000000000000000000),(97,103,2000000000000000000000000),(18880,131,1000000000000000000000000)]") \
  <CONTRACT_ADDRESS> \
  src/ZKBridgeToken.sol:ZKBridgeToken \
  --etherscan-api-key $BSCSCAN_API_KEY
```

### EXPchain Testnet

```bash
# If explorer supports API
forge verify-contract \
  --chain-id 18880 \
  --constructor-args $(cast abi-encode "constructor(string,string,address,address,(uint256,uint16,uint256)[])" \
    "ZKBridgeToken" \
    "ZBT" \
    "0x129b0628A241e26D5048224c5B788E2D89CE6c40" \
    "0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7" \
    "[(11155111,119,3000000000000000000000000),(97,103,2000000000000000000000000),(18880,131,1000000000000000000000000)]") \
  <CONTRACT_ADDRESS> \
  src/ZKBridgeToken.sol:ZKBridgeToken \
  --etherscan-api-key $EXPCHAIN_EXPLORER_API_KEY
```

```bash
# If no API — flatten and upload manually
forge flatten src/ZKBridgeToken.sol > ZKBridgeTokenFlattened.sol
```

---

## Testing

```bash
forge test
```

Covers:

* Initial minting for each chain’s config.
* Cross-chain bridging with same address.
* Valid `zkReceive` from mapped chains.
* Reverts for invalid source chains.
* Reverts for deployment on unmapped chains.

---

## Usage

**Minting** (deployment mints to fixed address):

```solidity
0x129b0628A241e26D5048224c5B788E2D89CE6c40
```

**Estimate bridge fee:**

```bash
cast call <CONTRACT_ADDRESS> "estimateBridgeFee(uint16)(uint256)" 103 --rpc-url sepolia
```

**Bridge out:**

```bash
cast send <CONTRACT_ADDRESS> "bridgeOut(uint256,uint256,address)" \
  97 \
  1000000000000000000000 \
  0x129b0628A241e26D5048224c5B788E2D89CE6c40 \
  --rpc-url sepolia \
  --private-key $DEPLOYER_KEY \
  --value <FEE>
```

---

## Security Notes

* Only zkBridge contract can call `zkReceive`.
* Only known source chains allowed.
* Enforces identical address deployment via `CREATE2`.

---

## License

MIT License (see LICENSE file or SPDX headers).
