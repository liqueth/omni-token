# ZKBridgeToken

**ZKBridgeToken** is an **omnichain ERC-20 token** integrated with **Polyhedra zkBridge** for secure cross-chain transfers.
It is deployed to the **same address** across multiple chains using **CREATE2**, with **initial token minting configured per chain** via a `ChainConfig` array.

Cross-chain transfers are handled by **burning tokens on the source chain** and **minting on the destination chain** via zkBridge.

---

## Features

* **Omnichain Deployment** – Same contract address across all supported chains using `CREATE2`.
* **Polyhedra zkBridge Integration** – Secure cross-chain transfers with zero-knowledge proofs.
* **Configurable Minting** – Initial token supply per chain defined in constructor via `ChainConfig`:
* **Security** – Restricts `zkReceive` to mapped chains and validates same-address deployment.
* **Built with Foundry** – Deployment scripts, tests, and config via `foundry.toml`.

---

## Prerequisites

* [Foundry](https://book.getfoundry.sh/) (`forge`, `cast`)
* Git
* Environment variables for private key (`DEPLOYER_KEY`) and RPC endpoints (defined in `foundry.toml`)
* Block explorer accounts for verification (Etherscan, BscScan, etc.)
* Environment variables for verifier key (`ETHERSCAN_KEY`) and RPC endpoints (defined in `foundry.toml`)

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/liqueth/ZKBridgeToken.git
```

or

```bash
git clone git@github.com:liqueth/ZKBridgeToken.git
```

```bash
cd ZKBridgeToken
```

### 2. Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 4. Set environment variables

```bash
export DEPLOYER_ADDRESS=<YOUR_DEPLOYER_ADDRESS>
export DEPLOYER_KEY=<YOUR_PRIVATE_WALLET_KEY>
export ETHERSCAN_KEY=<YOUR_ETHERSCAN_KEY>
export ZK_BRIDGE_ADDRESS=0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7
```

### 5. Compile

```bash
forge build
```

---

## Deployment

```bash
CONFIG=config/mainnet.json forge script script/Deploy.s.sol --rpc-url eth --private-key $DEPLOYER_KEY --broadcast # Ethereum
```

```bash
CONFIG=config/testnet.json forge script script/Deploy.s.sol --rpc-url eth_test --private-key $DEPLOYER_KEY --broadcast # Ethereum Sepolia
```

```bash
CONFIG=config/testnet.json forge script script/Deploy.s.sol --rpc-url bsc_test --private-key $DEPLOYER_KEY --broadcast # BSC (BNB) Testnet
```

```bash
CONFIG=config/testnet.json forge script script/Deploy.s.sol --rpc-url exp_test --private-key $DEPLOYER_KEY --broadcast # EXPchain Testnet
```

```bash
# Save contract address displayed in commands above in environment variable
ZKBridgeToken=<CONTRACT_ADDRESS_DISPLAYED_ABOVE>
```

---

## Encode constructor arguments

```bash
CONSTRUCTOR_ARGS=$(cast abi-encode 'constructor(address,address,uint256[][])' $DEPLOYER_ADDRESS $(jq -r '.transactions[0].arguments[]' broadcast/Deploy.s.sol/$CHAIN/run-latest.json | tr -d ' '))
```

---

## Verification

```bash
# Save Standard Json-Input format to input.json
forge verify-contract --show-standard-json-input --constructor-args  $CONSTRUCTOR_ARGS $ZKBridgeToken src/ZKBridgeToken.sol:ZKBridgeToken > input.json
```

```bash
# Ethereum Sepolia
forge verify-contract --chain 11155111 --etherscan-api-key $ETHERSCAN_KEY --constructor-args  $CONSTRUCTOR_ARGS $ZKBridgeToken src/ZKBridgeToken.sol:ZKBridgeToken
forge verify-check $GUID --verifier etherscan --chain 11155111 -vvvvv --etherscan-api-key $ETHERSCAN_KEY
```

```bash
# BSC (BNB) Testnet
forge verify-contract $ZKBridgeToken src/ZKBridgeToken.sol:ZKBridgeToken --chain-id 97 --etherscan-api-key $ETHERSCAN_KEY --constructor-args  $CONSTRUCTOR_ARGS
```

```bash
# EXPchain Testnet
forge verify-contract $ZKBridgeToken src/ZKBridgeToken.sol:ZKBridgeToken --chain-id 18880 --etherscan-api-key $ETHERSCAN_KEY --constructor-args  $CONSTRUCTOR_ARGS
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

**Minting** (deployment mints to deployer):

**Estimate bridge fee:**

```bash
# 
cast call $ZKBridgeToken "bridgeFeeEstimate(uint256)" 97 --rpc-url eth_test
```

**Bridge out:**

```bash
cast send <CONTRACT_ADDRESS> "bridge(uint256,uint256)" \
  97 \
  1000000000000000000000 \
  --rpc-url <CHAIN> \
  --private-key $DEPLOYER_KEY \
  --value <FEE>
```

[[11155111,"3000000000000000000000"],[97,"2000000000000000000000"],[18880,"1000000000000000000000"]]

---

## Security Notes

* Only zkBridge contract can call `zkReceive`.
* Only known source chains allowed.
* Enforces identical address deployment via `CREATE2`.

---

## License

MIT License (see LICENSE file or SPDX headers).
