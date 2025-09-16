# executor.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/executor.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/executor.json
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
