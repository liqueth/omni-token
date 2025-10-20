#!/bin/bash
# Deploy DVN configs for all the dvns for a specified environment
# Usage: script/dvns.sh < io/$env/dvns.txt

while read dvn; do
    proto=io/$chain/AddressLookupProto.json config=io/$env/dvn/$dvn.json clone=io/$chain/dvn/$dvn.json forge script script/AddressLookupClone.s.sol -f $chain --private-key $tx_key --broadcast
done

jq -s 'add' io/$chain/dvn/*.json > io/$chain/dvn.json
