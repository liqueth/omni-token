#!/bin/bash

# Deploy all contracts for a given chain
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# CHAIN_ID=97 # BSC Testnet for example

OUT=io/$CHAIN_ID/AddressLookup.json forge script script/AddressLookup.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
script/AddressLookupClones.sh
proto=io/$CHAIN_ID/UintToUintProto.json forge script script/UintToUintProto.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10 ## --priority-gas-price 1gwei --with-gas-price 30gwei
proto=io/$CHAIN_ID/UintToUintProto.json config=io/testnet/endpointMapper.json clone=io/$CHAIN_ID/messaging.json forge script script/UintToUintClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
IN=io/$CHAIN_ID/messaging.json OUT=io/$CHAIN_ID/MessagingConfig.json forge script script/MessagingConfig.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
script/deployOmniToken.sh
