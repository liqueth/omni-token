jq --arg env $env -f jq/blocker.jq io/$env/deployments.json > io/$env/blocker.json
jq --arg env $env -f jq/endpointMapper.jq io/$env/deployments.json > io/$env/endpointMapper.json
jq --arg env $env -f jq/endpoint.jq io/$env/deployments.json > io/$env/endpoint.json
jq --arg env $env -f jq/executor.jq io/$env/deployments.json > io/$env/executor.json
jq --arg env $env -f jq/receiver.jq io/$env/deployments.json > io/$env/receiver.json
jq --arg env $env -f jq/sender.jq io/$env/deployments.json > io/$env/sender.json
