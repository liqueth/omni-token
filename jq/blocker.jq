# blocker.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/blocker.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/blocker.json
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
