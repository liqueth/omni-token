# config/rpc_endpoints.jq
# jq -f jq/rpc_endpoints.jq config/active.json > config/rpc_endpoints.json
# jq -f jq/rpc_endpoints.jq config/active.json | jq -r '.[] | "\(.chainId) = \(.rpcs)"' | sed '1i[rpc_endpoints]' > rpc_endpoints.toml
[
    .[]
    | select(((.rpcs // []) | length) > 0)
    | {
        key: .chainKey,
        chainId: .chainDetails.nativeChainId,
        rpcs: [((.rpcs // [])[] | . + {weight: -(.weight // 0)})]
        | sort_by(.weight)
        | [.[] | .url]
    }
]
