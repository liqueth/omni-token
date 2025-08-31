#!/bin/bash

forge script script/OmniMapProto.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify
export OmniMap=$(jq -r '.transactions[0].contractAddress' broadcast/OmniMapProto.s.sol/$CHAIN_ID/run-latest.json)
forge verify-contract -q --chain $CHAIN_ID --rpc-url $CHAIN_ID --etherscan-api-key $ETHERSCAN_KEY $OmniMap src/OmniMap.sol:OmniMap
