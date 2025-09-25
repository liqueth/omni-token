# receiver.jq
# Usage: jq --arg env $env -f jq/receiver.jq io/$env/deployments.json > io/$env/receiver.json
{
    env: $env,
    id: "receiver",
    keyValues: [
        .[]
        | {
            key: .chainId,
            value: .receiver
        }
    ]
}
