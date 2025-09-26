#!/bin/bash

# Generate all data files for deployments.
# Before running:
# source io/testnet.env
# Run:
# script/data.sh

jq -f jq/active.jq io/metadata.json > io/active.json
jq -sRf jq/nick.jq < io/nick.csv > io/nick.json
jq -sf jq/nickmeta.jq io/active.json io/nick.json > io/nickmeta.json
jq --arg env $env -f jq/deployments.jq io/nickmeta.json > io/$env/deployments.json

jq --arg env $env -f jq/blocker.jq io/$env/deployments.json > io/$env/blocker.json
jq --arg env $env -f jq/endpointMapper.jq io/$env/deployments.json > io/$env/endpointMapper.json
jq --arg env $env -f jq/endpoint.jq io/$env/deployments.json > io/$env/endpoint.json
jq --arg env $env -f jq/executor.jq io/$env/deployments.json > io/$env/executor.json
jq --arg env $env -f jq/receiver.jq io/$env/deployments.json > io/$env/receiver.json
jq --arg env $env -f jq/sender.jq io/$env/deployments.json > io/$env/sender.json
