# eid.jq
# Usage: jq --arg env $env -f jq/endpointMapper.jq io/$env/deployments.json > io/$env/endpointMapper.json
{
    env: $env,
    id: "endpointMapper",
    keyValues: [
        .[]
        | {
            key: .chainId,
            value: .eid
        }
    ]
}
