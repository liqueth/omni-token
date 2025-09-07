# executor.jq
# Usage: jq -f jq/executor.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/executor.json
[
    .[]
    | [.chainId, .executor]
]
