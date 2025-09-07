jq --arg env $CHAIN_ENV -f jq/blocker.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/blocker.json
jq --arg env $CHAIN_ENV -f jq/eid.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/eid.json
jq --arg env $CHAIN_ENV -f jq/endpoint.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/endpoint.json
jq --arg env $CHAIN_ENV -f jq/executor.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/executor.json
jq --arg env $CHAIN_ENV -f jq/receiver.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/receiver.json
jq --arg env $CHAIN_ENV -f jq/sender.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/sender.json
