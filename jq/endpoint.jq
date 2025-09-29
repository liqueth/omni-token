# endpoint.jq
# Usage: jq --arg env $env -f jq/endpoint.jq io/$env/deployments.json > io/$env/endpoint.json
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
