#!/bin/bash

# Deploy OmniToken and OMNI_ALPHA clone
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# script/all_deployments.sh
# CHAIN_ID=97 # BSC Testnet for example

proto=io/$CHAIN_ID/OmniTokenProto.json config=io/$CHAIN_ID/MessagingConfig.json forge script script/OmniTokenProto.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
proto=io/$CHAIN_ID/OmniTokenProto.json config=io/testnet/OMNI_ALPHA.json clone=io/$CHAIN_ID/OMNI_ALPHA.json forge script script/OmniTokenClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
