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
CHAIN_ID=11155111 # set to desired chain id 
```

```bash
TO_CHAIN_ID=97 # set destination chain id 
```

```bash
CONFIG=config/testnet.json forge script script/Deploy.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast # Testnets
```

```bash
CONFIG=config/mainnet.json forge script script/Deploy.s.sol --rpc-url eth --private-key $DEPLOYER_KEY --broadcast # Mainnets
```

```bash
# Save contract address displayed in commands above in environment variable
CONTRACT_ADDRESS=$(jq -r '.transactions[0].contractAddress' broadcast/Deploy.s.sol/$CHAIN_ID/run-latest.json)
```

---

## Encode constructor arguments

```bash
CONSTRUCTOR_ARGS=$(cast abi-encode 'constructor(address,address,uint256[][])' $DEPLOYER_ADDRESS $(jq -r '.transactions[0].arguments[]' broadcast/Deploy.s.sol/$CHAIN_ID/run-latest.json | tr -d ' '))
```

---

## Verification

```bash
# Save Standard Json-Input format to ZKBridgeToken.json
forge verify-contract --show-standard-json-input --constructor-args  $CONSTRUCTOR_ARGS $CONTRACT_ADDRESS src/ZKBridgeToken.sol:ZKBridgeToken > ZKBridgeToken.json
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
# Estimate bridge fee
FEE=$(cast call $CONTRACT_ADDRESS "bridgeFeeEstimate(uint256)" $TO_CHAIN_ID --rpc-url $CHAIN_ID); echo $FEE
```

**Bridge out:**

```bash
# set destination chain id
TO_CHAIN_ID=97 
```

```bash
# set destination chain id
MINTS='[[11155111,2e21],[97,3e21]]'
```

```bash
 # set destination chain id
 BRIDGE_AMOUNT=123e18 
```

```bash
cast send --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY $CONTRACT_ADDRESS "clone(address,string,string,uint256[][])" $DEPLOYER_ADDRESS "Bridge Clone" "BCLN" $MINTS
```

```bash
cast send --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --value $FEE $CONTRACT_ADDRESS "bridge(uint256,uint256)" $TO_CHAIN_ID $BRIDGE_AMOUNT
```

---

## Security Notes

* Only zkBridge contract can call `zkReceive`.
* Only known source chains allowed.
* Enforces identical address deployment via `CREATE2`.

---

## License

MIT License (see LICENSE file or SPDX headers).
