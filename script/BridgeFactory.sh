#!/bin/bash

# Deploy BridgeFactory and BridgeProto clone
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# script/chain.sh
# chain=97 # BSC Testnet for example

factory=io/$chain/BridgeFactory.json forge script script/BridgeFactory.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
proto=io/$chain/BridgeProto.json factory=io/$chain/BridgeFactory.json config=io/$chain/MessagingConfig.json forge script script/BridgeProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
script/verifyBridgeDeterministic.sh
