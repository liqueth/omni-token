#!/bin/bash

: '

Usage:
script/OmniAddressClones.sh
'

OmniAddressPath=config/$CHAIN_ENV/blocker.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --broadcast
OmniAddressPath=config/$CHAIN_ENV/endpoint.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --broadcast
OmniAddressPath=config/$CHAIN_ENV/executor.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --broadcast
OmniAddressPath=config/$CHAIN_ENV/receiver.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --broadcast
OmniAddressPath=config/$CHAIN_ENV/sender.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --broadcast
