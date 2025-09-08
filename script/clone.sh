#!/bin/bash

source config/testnet.env
OmniAddressPath=config/$CHAIN_ENV/blocker.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
OmniAddressPath=config/$CHAIN_ENV/endpoint.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
OmniAddressPath=config/$CHAIN_ENV/executor.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
OmniAddressPath=config/$CHAIN_ENV/receiver.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
OmniAddressPath=config/$CHAIN_ENV/sender.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast


OmniAddressPath=config/$CHAIN_ENV/dvn/bitgo.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
OmniAddressPath=config/$CHAIN_ENV/dvn/frax.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
OmniAddressPath=config/$CHAIN_ENV/dvn/gitcoin.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
OmniAddressPath=config/$CHAIN_ENV/dvn/google-cloud.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
OmniAddressPath=config/$CHAIN_ENV/dvn/layerzero-labs.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
