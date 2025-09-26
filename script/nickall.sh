#!/bin/bash

# Find which chains have the nick's arachnid deployer contract
# Usage: script/nickall.sh

jq -f jq/active.jq io/metadata.json > io/active.json
jq -f jq/rpc.jq io/active.json > io/rpc.json
jq -r '.[] | join(",")' < io/rpc.json > io/rpc.csv

script/nick.sh < io/rpc.csv > io/nick.csv
