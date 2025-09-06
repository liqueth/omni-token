#!/bin/bash

forge script script/OmniAddress.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify --delay 10 --retries 10
export OmniAddress=$(jq -r '.transactions[0].contractAddress' broadcast/OmniAddress.s.sol/$CHAIN_ID/run-latest.json)
forge verify-contract -q --chain $CHAIN_ID --rpc-url $CHAIN_ID --etherscan-api-key $ETHERSCAN_KEY $OmniAddress src/OmniAddress.sol:OmniAddress
