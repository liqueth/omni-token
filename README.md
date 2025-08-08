ZKBridgeToken
ZKBridgeToken is an omnichain ERC-20 token integrated with Polyhedra zkBridge for secure cross-chain transfers. It is deployed to the same address across multiple chains using CREATE2, with initial token minting configured per chain via a ChainConfig array. The total supply is fixed and minted only during deployment, with cross-chain transfers handled by burning tokens on the source chain and minting on the destination chain via zkBridge.
Features

Omnichain Deployment: Same contract address across all supported chains using CREATE2.
Polyhedra zkBridge Integration: Secure cross-chain transfers with zero-knowledge proofs.
Configurable Minting: Initial token supply per chain defined in the constructor via ChainConfig (EVM chain ID, zkBridge chain ID, mint amount).
Security: Restricts zkReceive to mapped chains and validates same-address deployment.
Built with Foundry: Includes deployment scripts, tests, and configuration via foundry.toml.

Repository Structure

src/ZKBridgeToken.sol: Main token contract implementing ERC-20 and zkBridge integration.
src/interfaces/IZKBridge.sol: Interface for zkBridge send functionality.
src/interfaces/IZKBridgeReceiver.sol: Interface for zkBridge receive functionality.
script/Deploy.s.sol: Deployment script using CREATE2.
test/ZKBridgeToken.t.sol: Test suite for minting, bridging, and edge cases.
foundry.toml: Configuration with RPC endpoints for supported chains.

Prerequisites

Foundry (forge, cast)
Git
Environment variables for private key (DEPLOYER_KEY) and RPC endpoints (defined in foundry.toml)
Node.js (optional, for additional scripting)
Accounts on block explorers (e.g., Etherscan, BscScan) for contract verification

Setup

Clone the Repository:
git clone https://github.com/liqueth/ZKBridgeToken.git
cd ZKBridgeToken


Install Foundry (if not already installed):
curl -L https://foundry.paradigm.xyz | bash
foundryup


Configure foundry.toml:Ensure foundry.toml includes RPC endpoints for supported chains. Example:
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.30"

[rpc_endpoints]
sepolia = "${SEPOLIA_RPC}"
bsc_testnet = "${BSC_TESTNET_RPC}"
expchain_testnet = "${EXPCHAIN_TESTNET_RPC}"

Set environment variables for RPC URLs:
export SEPOLIA_RPC=<SEPOLIA_RPC_URL>
export BSC_TESTNET_RPC=<BSC_TESTNET_RPC_URL>
export EXPCHAIN_TESTNET_RPC=<EXPCHAIN_TESTNET_RPC_URL>
export DEPLOYER_KEY=<YOUR_PRIVATE_KEY>


Install Dependencies:Install OpenZeppelin contracts:
forge install OpenZeppelin/openzeppelin-contracts

Ensure remappings.txt includes:
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/


Compile the Project:
forge build



Deployment
The contract is deployed using CREATE2 to ensure the same address across chains. The deployment script (script/Deploy.s.sol) configures three testnet chains:

Sepolia (EVM 11155111, zkBridge 119): 3,000,000 tokens minted.
BSC Testnet (EVM 97, zkBridge 103): 2,000,000 tokens minted.
EXPchain Testnet (EVM 18880, zkBridge 131): 1,000,000 tokens minted.

Steps

Deploy on Sepolia:
forge script script/Deploy.s.sol --rpc-url sepolia --private-key $DEPLOYER_KEY --broadcast


Deploy on BSC Testnet:
forge script script/Deploy.s.sol --rpc-url bsc_testnet --private-key $DEPLOYER_KEY --broadcast


Deploy on EXPchain Testnet:
forge script script/Deploy.s.sol --rpc-url expchain_testnet --private-key $DEPLOYER_KEY --broadcast

Note: Use the same salt (default: 1234) in Deploy.s.sol for all chains to ensure the same address.

Alternative: Deploy with forge create:Encode constructor arguments:
cast abi-encode "constructor(string,string,address,address,(uint256,uint16,uint256)[])" \
    "ZKBridgeToken" \
    "ZBT" \
    "0x129b0628A241e26D5048224c5B788E2D89CE6c40" \
    "0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7" \
    "[(11155111,119,3000000000000000000000000),(97,103,2000000000000000000000000),(18880,131,1000000000000000000000000)]"

Deploy with:
forge create src/ZKBridgeToken.sol:ZKBridgeToken \
    --rpc-url sepolia \
    --private-key $DEPLOYER_KEY \
    --constructor-args <ENCODED_ARGS_FROM_ABOVE> \
    --create2-salt 1234

Repeat for bsc_testnet and expchain_testnet RPC endpoints.


Contract Verification
Verify the deployed contract on each chain’s block explorer to make the source code publicly accessible.

Verify on Sepolia (Etherscan):
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
    --etherscan-api-key <ETHERSCAN_API_KEY>


Verify on BSC Testnet (BscScan):
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
    --etherscan-api-key <BSCSCAN_API_KEY>


Verify on EXPchain Testnet:EXPchain’s block explorer may vary (check Polyhedra’s documentation for the correct explorer). If available, use:
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
    --etherscan-api-key <EXPCHAIN_EXPLORER_API_KEY>

Note: If EXPchain lacks a public explorer, manual verification may be required (e.g., publish source code on GitHub).

Set API Keys:Obtain API keys from:

Etherscan for Sepolia
BscScan for BSC Testnet
EXPchain explorer (if available)Set environment variables:

export ETHERSCAN_API_KEY=<YOUR_ETHERSCAN_API_KEY>
export BSCSCAN_API_KEY=<YOUR_BSCSCAN_API_KEY>
export EXPCHAIN_EXPLORER_API_KEY=<YOUR_EXPCHAIN_API_KEY>



Testing
Run the test suite to verify contract functionality:
forge test

The test suite (test/ZKBridgeToken.t.sol) covers:

Initial minting on chains with non-zero mintAmount (Sepolia: 3M, BSC Testnet: 2M, EXPchain: 1M).
Cross-chain bridging with same address.
Successful zkReceive from mapped chains.
Reverts for zkReceive from unmapped chains.
Reverts for deployment on unmapped chains.

Usage

Minting: Tokens are minted to 0x129b0628A241e26D5048224c5B788E2D89CE6c40 during deployment based on ChainConfig.mintAmount.
Bridging: Use bridgeOut(uint256 dstEvmChainId, uint256 amount, address recipient) to transfer tokens. Example:cast call <CONTRACT_ADDRESS> "estimateBridgeFee(uint16)(uint256)" 103 --rpc-url sepolia
cast send <CONTRACT_ADDRESS> "bridgeOut(uint256,uint256,address)" 97 1000000000000000000000 0x129b0628A241e26D5048224c5B788E2D89CE6c40 --rpc-url sepolia --private-key $DEPLOYER_KEY --value <FEE>


Cross-Chain Receive: The zkReceive function is called by the zkBridge contract (0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7 on testnets) to mint tokens on the destination chain.

Notes

Chain IDs: Testnet chain IDs are from Polyhedra’s documentation (Sepolia: 119, BSC Testnet: 103, EXPchain: 131). Verify mainnet IDs via Polyhedra’s docs.
Security: Audit the contract before mainnet deployment. Consider adding events for bridgeOut and zkReceive for logging.
Mainnet Deployment: Update zkBridgeAddr and chain IDs in Deploy.s.sol for mainnet. Obtain mainnet zkBridge address from Polyhedra.
CREATE2: Ensure the same salt is used across all chains for consistent addresses.
Verification: Some explorers may require flattened contracts. Use forge flatten src/ZKBridgeToken.sol > ZKBridgeTokenFlattened.sol if needed.

License
MIT License (see LICENSE file or contract SPDX headers).