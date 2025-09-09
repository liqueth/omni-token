#!/bin/bash

UintToAddressPath=config/testnet/dvn/google-cloud.json forge script script/UintToAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
