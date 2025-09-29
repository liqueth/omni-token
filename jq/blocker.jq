# blocker.jq
# Usage: jq --arg env $env -f jq/blocker.jq io/$env/deployments.json > io/$env/blocker.json
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
