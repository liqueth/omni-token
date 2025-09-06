# blocker.jq
# Usage: jq -f jq/eid.jq config/deployments-mainnet.json > config/eid-mainnet.json
# Usage: jq -f jq/eid.jq config/deployments-testnet.json > config/eid-testnet.json
[
    .[]
    | [.chainId, .eid]
]
