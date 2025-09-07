# endpoint.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/endpoint.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/endpoint.json
{
    env: $env,
    id: "endpoint",
    keyValues: [
        .[]
        | {
            key: .chainId,
            value: .endpoint
        }
    ]
}
