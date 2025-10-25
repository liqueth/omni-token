#!/bin/bash

# Deploy OFTBridgeFactory and OFTMinterProto clone
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# script/chain.sh
# chain=97 # BSC Testnet for example

factory=io/$chain/OFTBridgeFactory.json forge script script/OFTBridgeFactory.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
proto=io/$chain/OFTMinterProto.json factory=io/$chain/OFTBridgeFactory.json config=io/$chain/MessagingConfig.json forge script script/OFTMinterProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
script/verifyOFTMinterDeterministic.sh
