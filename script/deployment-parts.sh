jq -f jq/blocker.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/blocker.json
jq -f jq/eid.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/eid.json
jq -f jq/endpoint.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/endpoint.json
jq -f jq/executor.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/executor.json
jq -f jq/receiver.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/receiver.json
jq -f jq/sender.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/sender.json
