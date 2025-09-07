# blocker.endpoint
# Usage: jq -f jq/endpoint.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/endpoint.json
[
    .[]
    | [.chainId, .endpoint]
]
