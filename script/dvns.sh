#!/bin/bash
# Deploy DVN configs for all the dvns for a specified environment
# Usage: script/UintToAddressProto.sh < config/$env/dvns.txt

while read dvn; do
    UintToAddressPath=config/$env/dvn/$dvn.json forge script script/UintToAddressClone.s.sol -f $chain --private-key $tx_key --broadcast
done
