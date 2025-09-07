# eid.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/eid.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/eid.json
{
    env: $env,
    id: "eid",
    keyValues: [
        .[]
        | {
            key: .chainId,
            value: .eid
        }
    ]
}
