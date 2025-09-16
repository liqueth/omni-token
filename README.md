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
* Environment variables for verifier key (`ETHERSCAN_API_KEY`) and RPC endpoints (defined in `foundry.toml`)

---

## Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Restart your shell to recognize the updated path.

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

Set the following environment variables (in your .bashrc).

```bash
export RAW_PRIVATE_KEY=<YOUR_PRIVATE_WALLET_KEY>
export ETHERSCAN_API_KEY=<YOUR_ETHERSCAN_API_KEY>
```

RAW_PRIVATE_KEY is the private key of the Ethereum account you want to use to initiate transactions such as deploying contracts.
Get your ETHERSCAN_API_KEY at [Etherscan](https://etherscan.io/myaccount).

Other environment variables that will come into play include the following.

```bash
export CHAIN_ENV=mainnet
export CHAIN_ENV=testnet
export CHAIN_ID=97 # BNB testnet
export CHAIN_ID=137 # Polygon
export CHAIN_ID=11155111 # Sepolia, set to desired chain id
export TO_CHAIN_ID=10 # Optimism
export TO_CHAIN_ID=97 # BNB test, set destination chain id
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

## License

MIT License (see LICENSE file or SPDX headers).
