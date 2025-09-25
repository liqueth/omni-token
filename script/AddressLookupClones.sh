#!/bin/bash

: '

Usage:
script/AddressLookupClones.sh
'

CLN=io/$CHAIN_ID/AddressLookup.json IN=io/testnet/blocker.json OUT=io/$CHAIN_ID/messaging.json forge script script/AddressLookupClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
CLN=io/$CHAIN_ID/AddressLookup.json IN=io/testnet/endpoint.json OUT=io/$CHAIN_ID/messaging.json forge script script/AddressLookupClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
CLN=io/$CHAIN_ID/AddressLookup.json IN=io/testnet/executor.json OUT=io/$CHAIN_ID/messaging.json forge script script/AddressLookupClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
CLN=io/$CHAIN_ID/AddressLookup.json IN=io/testnet/receiver.json OUT=io/$CHAIN_ID/messaging.json forge script script/AddressLookupClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
CLN=io/$CHAIN_ID/AddressLookup.json IN=io/testnet/sender.json OUT=io/$CHAIN_ID/messaging.json forge script script/AddressLookupClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
