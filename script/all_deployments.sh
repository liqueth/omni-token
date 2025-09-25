#!/bin/bash

# Deploy all contracts for a given chain
# prerequesite before running:
# source config/testnet.env
# or
# source config/testnet.env
# chain=421614 # Arbitrum Testnet for example

script/prep_chain.sh

proto=io/$chain/UintToUintProto.json forge script script/UintToUintProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10 ## --priority-gas-price 1gwei --with-gas-price 30gwei
proto=io/$chain/UintToUintProto.json config=io/testnet/endpointMapper.json clone=io/$chain/messaging.json forge script script/UintToUintClone.s.sol -f $chain --private-key $tx_key --broadcast

proto=io/$chain/AddressLookupProto.json forge script script/AddressLookupProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
proto=io/$chain/AddressLookupProto.json config=io/testnet/blocker.json messaging=io/$chain/messaging.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast
proto=io/$chain/AddressLookupProto.json config=io/testnet/endpoint.json messaging=io/$chain/messaging.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast
proto=io/$chain/AddressLookupProto.json config=io/testnet/executor.json messaging=io/$chain/messaging.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast
proto=io/$chain/AddressLookupProto.json config=io/testnet/receiver.json messaging=io/$chain/messaging.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast
proto=io/$chain/AddressLookupProto.json config=io/testnet/sender.json messaging=io/$chain/messaging.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast

IN=io/$chain/messaging.json OUT=io/$chain/MessagingConfig.json forge script script/MessagingConfig.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10

script/deployOmniToken.sh
