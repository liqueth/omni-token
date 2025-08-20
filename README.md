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
export CONFIG=config/mainnet.json
export CONFIG=config/testnet.json
export MINTS='[1,1e21],[56,1e21],[137,1e21],[43114,1e21],[250,1e21],[10,1e21],[42161,1e21],[1284,1e21],[100,1e21],[1088,1e21],[42170,1e21],[1116,1e21],[42220,1e21],[59144,1e21],[5000,1e21],[8453,1e21],[204,1e21],[534352,1e21]' # main
export MINTS='[[11155111,2e21],[97,3e21]]' # test
export BRIDGE_AMOUNT=123e16
export CHAIN_ID=11155111 # Sepolia, set to desired chain id 
export TO_CHAIN_ID=97 # BNB test, set destination chain id
export CLONE_NAME='Omnicoin test'
export CLONE_SYMBOL=OMNIT
```

### 5. Compile

```bash
forge build
```

---

## Deployment

```bash
# Deploy the token factory/implementation
forge script script/Deploy.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
```

```bash
# Save contract address displayed in commands above in environment variable
export CONTRACT_ADDRESS=$(jq -r '.transactions[0].contractAddress' broadcast/Deploy.s.sol/$CHAIN_ID/run-latest.json); echo $CONTRACT_ADDRESS
```

---

## Encode constructor arguments

```bash
export CONSTRUCTOR_ARGS=$(cast abi-encode 'constructor(address,uint256[][])' $(jq -r '.transactions[0].arguments[]' broadcast/Deploy.s.sol/$CHAIN_ID/run-latest.json | tr -d ' ' | xargs)); echo $CONSTRUCTOR_ARGS
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
FEE=$(cast call $CONTRACT_ADDRESS "bridgeFeeEstimate(uint256)(uint256)" $TO_CHAIN_ID --rpc-url $CHAIN_ID); echo $FEE
```

**Bridge out:**

```bash
# swap chains
TEMP_CHAIN_ID=$TO_CHAIN_ID;export TO_CHAIN_ID=$CHAIN_ID;export CHAIN_ID=$TEMP_CHAIN_ID
```

```bash
# Deploy a cloned token
cast send --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY $CONTRACT_ADDRESS "clone(address,string,string,uint256[][])" $DEPLOYER_ADDRESS "$CLONE_NAME" "$CLONE_SYMBOL" $MINTS
```

```bash
# bridge clone token
cast send --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --value $FEE $CLONE_ADDRESS "bridge(uint256,uint256)" $TO_CHAIN_ID $BRIDGE_AMOUNT
```

```bash
# Balance of cloned test
cast call --rpc-url $CHAIN_ID $CLONE_ADDRESS "balanceOf(address)(uint256)" $DEPLOYER_ADDRESS
```

---

## Security Notes

* Only zkBridge contract can call `zkReceive`.
* Only known source chains allowed.
* Enforces identical address deployment via `CREATE2`.

---

## License

MIT License (see LICENSE file or SPDX headers).
