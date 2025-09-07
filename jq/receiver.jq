# receiver.jq
# Usage: jq -f jq/receiver.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/receiver.json
[
    .[]
    | [.chainId, .receiver]
]
