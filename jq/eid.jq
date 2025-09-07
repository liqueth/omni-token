# blocker.jq
# Usage: jq -f jq/eid.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/eid.json
[
    .[]
    | [.chainId, .eid]
]
