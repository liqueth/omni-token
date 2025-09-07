# sender.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/sender.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/sender.json
{
    env: $env,
    id: "sender",
    keyValues: [
        .[]
        | {
            key: .chainId,
            value: .sender
        }
    ]
}
