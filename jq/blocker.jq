# blocker.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/blocker.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/blocker.json
{
    env: $env,
    id: "blocker",
    keyValues: [
        .[]
        | {
            key: .chainId,
            value: .blocker
        }
    ]
}
