# eid.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/eid.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/eid.json
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
