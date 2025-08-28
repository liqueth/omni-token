# OmniToken

**OmniToken** is an **omnichain ERC-20 token** integrated with **Polyhedra zkBridge** for secure cross-chain transfers.
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

## Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## Clone the repository

```bash
git clone https://github.com/liqueth/omni-token.git
```

or

```bash
git clone git@github.com:liqueth/omni-token.git
```

```bash
cd omni-token
```

## Set environment variables

```bash
export DEPLOYER_ADDRESS=<YOUR_DEPLOYER_ADDRESS>
export DEPLOYER_KEY=<YOUR_PRIVATE_WALLET_KEY>
export ETHERSCAN_KEY=<YOUR_ETHERSCAN_KEY>
export Layer0V2MetaConfigPath=config/Layer0V2Meta/layer0_mainnet.json
export Layer0V2MetaConfigPath=config/Layer0V2Meta/layer0_testnet.json
export ZK_BRIDGE_ADDRESS=0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7
export CHAIN_ENV=mainnet
export CHAIN_ENV=testnet
export EndpointConfigPath=config/EndpointConfig/mainnet.json
export EndpointConfigPath=config/EndpointConfig/testnet.json
export FixedOmniTokenConfigPath=config/FixedOmniToken/mainnet.json
export FixedOmniTokenConfigPath=config/FixedOmniToken/testnet.json
export MINTS='[[1,1e21],[10,1e21],[56,1e21],[100,1e21],[137,1e21],[204,1e21],[250,1e21],[1088,1e21],[1116,1e21],[1284,1e21],[5000,1e21],[8453,1e21],[42161,1e21],[42170,1e21],[42220,1e21],[43114,1e21],[59144,1e21],[534352,1e21]]' # main
export MINTS='[[97,3e21],[11155111,2e21]]' # test
export BRIDGE_AMOUNT=123e16
export CHAIN_ID=97 # BNB testnet 
export CHAIN_ID=137 # Polygon 
export CHAIN_ID=11155111 # Sepolia, set to desired chain id 
export TO_CHAIN_ID=10 # Optimism
export TO_CHAIN_ID=97 # BNB test, set destination chain id
export CLONE_NAME='Omnicoin Alpha'
export CLONE_SYMBOL=OMNIA
```

```bash
# swap CHAIN_ID and TO_CHAIN_ID
TEMP_CHAIN_ID=$TO_CHAIN_ID;export TO_CHAIN_ID=$CHAIN_ID;export CHAIN_ID=$TEMP_CHAIN_ID
```

---

## Compile

```bash
forge build
```

---

## Test

```bash
forge test
```

---

## Deploy Layer0V2Meta

```bash
# Deploy the token factory/implementation
forge script script/Layer0V2Meta.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
```

```bash
# Save contract address displayed in commands above in environment variable
export CONTRACT_ADDRESS=$(jq -r '.transactions[0].contractAddress' broadcast/FixedOmniToken.s.sol/$CHAIN_ID/run-latest.json); echo $CONTRACT_ADDRESS
```

---

## Generate EndpointConfig data

```bash
export CHAIN_ENV=testnet
jq --arg env $CHAIN_ENV --argjson version 2 --indent 4 -f config/EndpointConfig/endpoint.jq config/Layer0V2Meta/metadata.json > config/EndpointConfig/$CHAIN_ENV.json
```

---

---

## Generate DVN data

```bash
export CHAIN_ENV=testnet; export DVN_ID=polyhedra-network;
jq --arg id $DVN_ID --arg env $CHAIN_ENV --argjson version 2 --indent 4 -f config/VerifierConfig/verifier.jq config/Layer0V2Meta/metadata.json > config/VerifierConfig/$CHAIN_ENV.json
```

---


## Deploy EndpointConfig

```bash
# Deploy the token factory/implementation
forge script script/EndpointConfig.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
```

```bash
# Save contract address displayed in commands above in environment variable
export EndpointConfigAddress=$(jq -r '.transactions[0].contractAddress' broadcast/EndpointConfig.s.sol/$CHAIN_ID/run-latest.json); echo $EndpointConfigAddress
```

```bash
export EndpointConfigArgs=$(cast abi-encode 'constructor(((address,uint256,uint32,address,address,address,address)[]))' $(jq -r '.transactions[0].arguments[]' broadcast/EndpointConfig.s.sol/$CHAIN_ID/run-latest.json | tr -d ' ' | xargs)); echo $EndpointConfigArgs
```

```bash
# Save Standard Json-Input format to EndpointConfig.json
forge verify-contract --show-standard-json-input --constructor-args  $EndpointConfigArgs $EndpointConfigAddress src/EndpointConfig.sol:EndpointConfig > EndpointConfig.json
```

---

## Deploy VerifierConfig

```bash
# Deploy the token factory/implementation
forge script script/VerifierConfig.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
```

```bash
# Save contract address displayed in commands above in environment variable
export VerifierConfigAddress=$(jq -r '.transactions[0].contractAddress' broadcast/VerifierConfig.s.sol/$CHAIN_ID/run-latest.json); echo $VerifierConfigAddress
```

```bash
export VerifierConfigArgs=$(cast abi-encode 'constructor(((uint32,address)[],string,uint256))' $(jq -r '.transactions[0].arguments[]' broadcast/VerifierConfig.s.sol/$CHAIN_ID/run-latest.json | tr -d ' ' | xargs)); echo $VerifierConfigArgs
```

```bash
# Save Standard Json-Input format to VerifierConfig.json
forge verify-contract --show-standard-json-input --constructor-args  $VerifierConfigArgs $VerifierConfigAddress src/VerifierConfig.sol:VerifierConfig > VerifierConfig.json
```

---

## Deploy

```bash
# Deploy the token factory/implementation
forge script script/FixedOmniToken.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
```

```bash
# Save contract address displayed in commands above in environment variable
export CONTRACT_ADDRESS=$(jq -r '.transactions[0].contractAddress' broadcast/FixedOmniToken.s.sol/$CHAIN_ID/run-latest.json); echo $CONTRACT_ADDRESS
```

---

## Encode constructor arguments

```bash
export CONSTRUCTOR_ARGS=$(cast abi-encode 'constructor(address,uint256[][])' $(jq -r '.transactions[0].arguments[]' broadcast/FixedOmniToken.s.sol/$CHAIN_ID/run-latest.json | tr -d ' ' | xargs)); echo $CONSTRUCTOR_ARGS
```

---

## Verify

```bash
# Save Standard Json-Input format to FixedOmniToken.json
forge verify-contract --show-standard-json-input --constructor-args  $CONSTRUCTOR_ARGS $CONTRACT_ADDRESS src/FixedOmniToken.sol:FixedOmniToken > FixedOmniToken.json
```

Submit FixedOmniToken.json to a verification service like Etherscan. Use their API or web interface to upload the file and verify the contract at `CONTRACT_ADDRESS`. 
For detailed instructions, see: https://docs.etherscan.io/contract-verification.

---

## Deploy a cloned token

```bash
# Deploy a cloned token
cast send --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY $CONTRACT_ADDRESS "clone(address,string,string,uint256[][])" $DEPLOYER_ADDRESS "$CLONE_NAME" "$CLONE_SYMBOL" $MINTS
```

## Bridge tokens to another chain

```bash
# Estimate bridge fee
export BRIDGE_FEE=$(cast call $CLONE_ADDRESS "bridgeFeeEstimate(uint256)(uint256)" $TO_CHAIN_ID --rpc-url $CHAIN_ID | awk '{print $1}'); echo $BRIDGE_FEE
```

```bash
# bridge clone token
cast send --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --value $BRIDGE_FEE $CLONE_ADDRESS "bridge(uint256,uint256)" $TO_CHAIN_ID $BRIDGE_AMOUNT
```

---

## Security Notes

* Only zkBridge contract can call `zkReceive`.
* Only known source chains allowed.
* Enforces identical address deployment via `CREATE2`.

---

## License

MIT License (see LICENSE file or SPDX headers).
