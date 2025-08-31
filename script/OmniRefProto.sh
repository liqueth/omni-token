#!/bin/bash

forge script script/OmniRefProto.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify
export OmniRef=$(jq -r '.transactions[0].contractAddress' broadcast/OmniRefProto.s.sol/$CHAIN_ID/run-latest.json)
forge verify-contract -q --chain $CHAIN_ID --rpc-url $CHAIN_ID --etherscan-api-key $ETHERSCAN_KEY $OmniRef src/OmniRef.sol:OmniRef
