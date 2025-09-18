#!/bin/bash

# Deploy all contracts for a given chain
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# CHAIN_ID=97 # BSC Testnet for example

OUT=io/$CHAIN_ID/OmniAddress.json forge script script/OmniAddress.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
script/OmniAddressClones.sh
OUT=io/$CHAIN_ID/UintToUint.json forge script script/UintToUint.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
CLN=io/$CHAIN_ID/UintToUint.json IN=io/testnet/endpointMapper.json OUT=io/$CHAIN_ID/messaging.json forge script script/UintToUintClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
IN=io/$CHAIN_ID/messaging.json OUT=io/$CHAIN_ID/MessagingConfig.json forge script script/MessagingConfig.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
IN=io/$CHAIN_ID/MessagingConfig.json OUT=io/$CHAIN_ID/OmniToken.json forge script script/OmniToken.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
CLN=io/$CHAIN_ID/OmniToken.json IN=io/testnet/OMNI_ALPHA.json OUT=io/$CHAIN_ID/OMNI_ALPHA.json forge script script/OmniTokenClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
