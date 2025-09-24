#!/bin/bash

# Deploy OmniToken and OMNI_ALPHA clone
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# script/all_deployments.sh
# CHAIN_ID=97 # BSC Testnet for example

CONFIG=io/$CHAIN_ID/MessagingConfig.json PROTO=io/$CHAIN_ID/OmniTokenProto.json forge script script/OmniTokenProto.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
PROTO=io/$CHAIN_ID/OmniTokenProto.json CONFIG=io/testnet/OMNI_ALPHA.json CLONE=io/$CHAIN_ID/OMNI_ALPHA.json forge script script/OmniTokenClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
