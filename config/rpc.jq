# config/rpc.jq
# jq -r -f config/rpc.jq config/metadata.json > config/rpc.json
def rpad($len; $ch):
  (. + ($ch * $len))[:$len];
[
    .[]?
    | del(.deployments, .dvns, .addressToOApp, .tokens)
    | . + .chainDetails
    | select(.chainStatus == "ACTIVE"
        and .chainType == "evm"
        and .nativeChainId)
    | select(((.rpcs // []) | length) > 0)
    | . + {rpcs: [((.rpcs // [])[] | . + {weight: -(.weight // 0)})] | sort_by(.weight) | [to_entries[] | {rpcrank: .key} + .value]}
    | . + (.rpcs[])
    | {
        rpc: .url,
        chainId: .nativeChainId,
        order: .rpcrank
    }
]
| sort_by(.chainId, .order)

