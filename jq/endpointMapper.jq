# eid.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/endpointMapper.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/endpointMapper.json
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
