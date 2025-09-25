#!/bin/bash
# Deploy DVN configs for all the dvns for a specified environment
# Usage: script/UintToAddressProto.sh < config/$CHAIN_ENV/dvns.txt

while read dvn; do
    UintToAddressPath=config/$CHAIN_ENV/dvn/$dvn.json forge script script/UintToAddressClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
done
