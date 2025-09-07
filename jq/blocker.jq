# blocker.jq
# Usage: jq -f jq/blocker.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/blocker.json
[
    .[]
    | [.chainId, .blocker]
]
