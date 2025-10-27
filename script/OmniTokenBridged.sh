#!/bin/bash

# Deploy BridgeFactory and BridgeProto clone
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# script/chain.sh
# chain=97 # BSC Testnet for example

echo "[*] Starting OmniTokenBridged.sh for chain $chain on env $env"

factory=io/$chain/OmniTokenBridgedFactory.json forge script script/OmniTokenBridgedFactory.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
factory=io/$chain/OmniTokenBridgedFactory.json config=io/$env/OMNIB.json bridge=io/$chain/BridgeProto.json proto=io/$chain/OmniTokenBridgedProto.json forge script script/OmniTokenBridgedProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
script/verifyOmniTokenBridgedProto.sh
