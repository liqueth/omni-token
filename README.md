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
* Environment variables for private key (`tx_key`) and RPC endpoints (defined in `foundry.toml`)
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
export tx_key=<YOUR_PRIVATE_WALLET_KEY>
export ETHERSCAN_API_KEY=<YOUR_ETHERSCAN_API_KEY>
```

The environment variable tx_key is the private key of the Ethereum account you want to use to initiate transactions such as deploying contracts.
Get your ETHERSCAN_API_KEY at [Etherscan](https://etherscan.io/myaccount).

Other environment variables that will come into play include the following.

```bash
export env=mainnet
export env=testnet
export chain=97 # BNB testnet
export chain=137 # Polygon
export chain=11155111 # Sepolia, set to desired chain id
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

## Deploy to a specific chain

```bash
source io/testnet.env
# or
# source io/mainnet.env
chain=11155111 # ethereum testnet
script/chain.sh
```

---

## License

MIT License (see LICENSE file or SPDX headers).
