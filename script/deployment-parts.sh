jq --arg env $CHAIN_ENV -f jq/blocker.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/blocker.json
jq --arg env $CHAIN_ENV -f jq/eid.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/eid.json
jq --arg env $CHAIN_ENV -f jq/endpoint.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/endpoint.json
jq --arg env $CHAIN_ENV -f jq/executor.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/executor.json
jq --arg env $CHAIN_ENV -f jq/receiver.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/receiver.json
jq --arg env $CHAIN_ENV -f jq/sender.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/sender.json
