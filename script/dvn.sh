#!/bin/bash
# Generate config data for all the dvns for a specified environment
# Usage: script/dvn.sh < config/$CHAIN_ENV/dvns.txt

while read dvn; do
    jq --arg env $CHAIN_ENV --arg id $dvn -f jq/dvn.jq config/nickmeta.json > config/$CHAIN_ENV/dvn/$dvn.json
done
