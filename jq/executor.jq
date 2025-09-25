# executor.jq
# Usage: jq --arg env $env -f jq/executor.jq io/$env/deployments.json > io/$env/executor.json
{
    env: $env,
    id: "executor",
    keyValues: [
        .[]
        | {
            key: .chainId,
            value: .executor
        }
    ]
}
