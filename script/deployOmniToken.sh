#!/bin/bash

# Deploy OmniToken and OMNI_ALPHA clone
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# script/all_deployments.sh
# CHAIN_ID=97 # BSC Testnet for example

IN=io/$CHAIN_ID/MessagingConfig.json OUT=io/$CHAIN_ID/OmniToken.json forge script script/OmniToken.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10 ## --priority-gas-price 100000000 --with-gas-price 1000000000
CLN=io/$CHAIN_ID/OmniToken.json IN=io/testnet/OMNI_ALPHA.json OUT=io/$CHAIN_ID/OMNI_ALPHA.json forge script script/OmniTokenClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
