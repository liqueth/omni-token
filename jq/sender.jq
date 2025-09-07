# sender.jq
# Usage: jq -f jq/sender.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/sender.json
[
    .[]
    | [.chainId, .sender]
]
