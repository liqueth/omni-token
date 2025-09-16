# endpoint.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/endpoint.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/endpoint.json
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
