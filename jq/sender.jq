# sender.jq
# Usage: jq --arg env $env -f jq/sender.jq io/$env/deployments.json > io/$env/sender.json
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
