# sender.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/sender.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/sender.json
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
