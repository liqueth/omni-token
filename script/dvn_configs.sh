#!/bin/bash
# Generate config data for all the dvns for a specified environment
# Usage: script/dvn_configs.sh < config/$env/dvns.txt

while read dvn; do
    jq --arg env $env --arg id $dvn -f jq/dvn.jq io/nickmeta.json > io/$env/dvn/$dvn.json
done
