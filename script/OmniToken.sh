#!/bin/bash

# Deploy OmniToken and OMNI_ALPHA clone
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# script/all_deployments.sh
# chain=97 # BSC Testnet for example

proto=io/$chain/OmniTokenProto.json config=io/$chain/MessagingConfig.json forge script script/OmniTokenProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
proto=io/$chain/OmniTokenProto.json config=io/testnet/OMNI_ALPHA.json clone=io/$chain/OMNI_ALPHA.json forge script script/OmniTokenClone.s.sol -f $chain --private-key $tx_key --broadcast
