# config/rpc.jq
# jq -f jq/rpc.jq config/active.json > io/rpc.json
# jq -f jq/rpc.jq config/active.json | jq -r '.[] | join(",")' > io/rpc.csv
[
    .[]?
    | select(.chainDetails.chainStatus == "ACTIVE"
        and .chainDetails.chainType == "evm"
        and .chainDetails.nativeChainId)
    | select(((.rpcs // []) | length) > 0)
    | . + {rpcs: [((.rpcs // [])[] | . + {rank: (.rank // 0)})] | sort_by(.rank) | [to_entries[] | {rank: .key} + .value]}
    | . + (.rpcs[])
    | {
        rpc: .url,
        chainId: .chainDetails.nativeChainId,
        rank: .rank,
        chainKey: .chainKey
    }
]
| sort_by(.chainId, .rank, .rpc | length)
