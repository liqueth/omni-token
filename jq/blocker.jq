# blocker.jq
# Usage: jq -f jq/blocker.jq config/deployments-mainnet.json > config/blocker-mainnet.json
# Usage: jq -f jq/blocker.jq config/deployments-testnet.json > config/blocker-testnet.json
[
    .[]
    | [.chainId, .blocker]
]
