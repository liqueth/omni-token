#!/bin/bash

forge script script/AddressLookup.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
export AddressLookup=$(jq -r '.transactions[0].contractAddress' broadcast/AddressLookup.s.sol/$CHAIN_ID/run-latest.json)
# forge verify-contract -q --chain $CHAIN_ID -f $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_API_KEY $AddressLookup src/AddressLookup.sol:AddressLookup
