#!/bin/bash
# Generate config data for all the dvns for a specified environment
# Usage: script/dvn_configs.sh < config/$CHAIN_ENV/dvns.txt

while read dvn; do
    jq --arg env $CHAIN_ENV --arg id $dvn -f jq/dvn.jq io/nickmeta.json > io/$CHAIN_ENV/dvn/$dvn.json
done
