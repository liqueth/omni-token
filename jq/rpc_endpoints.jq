# config/rpc_endpoints.jq
# jq -f jq/rpc_endpoints.jq config/active.json > config/rpc_endpoints.json
[
    .[]
    | select(((.rpcs // []) | length) > 0)
    | {
        chainKey: .chainKey,
        chainId: .chainDetails.nativeChainId,
        rpcs: [((.rpcs // [])[] | . + {weight: -(.weight // 0)})]
        | sort_by(.weight)
        | [.[] | .url]
        | (if (. | length == 1) then .[0] else . end)
    }
]
