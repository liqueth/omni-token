#!/bin/bash

# Deploy all contracts for a given chain
# prerequesite before running:
# source config/$env.env
# or
# source config/$env.env
# chain=421614 # Arbitrum Testnet for example

echo "[*] Starting chain.sh for chain $chain on env $env"

script/prep_chain.sh

proto=io/$chain/UintToUintProto.json forge script script/UintToUintProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10 ## --priority-gas-price 1gwei --with-gas-price 30gwei
proto=io/$chain/UintToUintProto.json config=io/$env/endpointMapper.json clone=io/$chain/messaging/endpointMapper.json forge script script/UintToUintClone.s.sol -f $chain --private-key $tx_key --broadcast

proto=io/$chain/AddressLookupProto.json forge script script/AddressLookupProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
proto=io/$chain/AddressLookupProto.json config=io/$env/blocker.json clone=io/$chain/messaging/blocker.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast
proto=io/$chain/AddressLookupProto.json config=io/$env/endpoint.json clone=io/$chain/messaging/endpoint.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast
proto=io/$chain/AddressLookupProto.json config=io/$env/executor.json clone=io/$chain/messaging/executor.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast
proto=io/$chain/AddressLookupProto.json config=io/$env/receiver.json clone=io/$chain/messaging/receiver.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast
proto=io/$chain/AddressLookupProto.json config=io/$env/sender.json clone=io/$chain/messaging/sender.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast

jq -s 'add' io/$chain/messaging/*.json > io/$chain/messaging.json

IN=io/$chain/messaging.json OUT=io/$chain/MessagingConfig.json forge script script/MessagingConfig.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10

script/OmniToken.sh

script/BridgeFactory.sh
script/BridgeProto.sh

script/OmniTokenBridgedFactory.sh
script/OmniTokenBridgedProto.sh

