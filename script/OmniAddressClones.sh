#!/bin/bash

: '

Usage:
script/OmniAddressClones.sh
'

CLN=io/$CHAIN_ID/OmniAddress.json IN=io/testnet/blocker.json OUT=io/$CHAIN_ID/messaging.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
CLN=io/$CHAIN_ID/OmniAddress.json IN=io/testnet/endpoint.json OUT=io/$CHAIN_ID/messaging.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
CLN=io/$CHAIN_ID/OmniAddress.json IN=io/testnet/executor.json OUT=io/$CHAIN_ID/messaging.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
CLN=io/$CHAIN_ID/OmniAddress.json IN=io/testnet/receiver.json OUT=io/$CHAIN_ID/messaging.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
CLN=io/$CHAIN_ID/OmniAddress.json IN=io/testnet/sender.json OUT=io/$CHAIN_ID/messaging.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
