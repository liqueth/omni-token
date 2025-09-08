# executor.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/executor.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/executor.json
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
