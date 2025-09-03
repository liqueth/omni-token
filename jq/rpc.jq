# config/rpc.jq
# jq -f config/rpc.jq config/metadata.json > config/rpc.json
# jq -f config/rpc.jq config/metadata.json | jq -r '.[] | join(",")' > config/rpc.csv
[
    .[]?
    | select(.chainDetails.chainStatus == "ACTIVE"
        and .chainDetails.chainType == "evm"
        and .chainDetails.nativeChainId)
    | select(((.rpcs // []) | length) > 0)
    | . + {rpcs: [((.rpcs // [])[] | . + {weight: -(.weight // 0)})] | sort_by(.weight) | [to_entries[] | {rpcrank: .key} + .value]}
    | . + (.rpcs[])
    | {
        rpc: .url,
        chainId: .chainDetails.nativeChainId,
        order: .rpcrank,
        chainName: .chainName
    }
]
| sort_by(.chainId, .order)
