# blocker.jq
# Usage: jq -f jq/endpoint.jq config/deployments-mainnet.json > config/endpoint-mainnet.json
# Usage: jq -f jq/endpoint.jq config/deployments-testnet.json > config/endpoint-testnet.json
[
    .[]
    | [.chainId, .endpoint]
]
