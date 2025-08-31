# config/rpc.jq
# jq -r -f config/rpc.jq config/metadata.json > config/rpc.txt
def rpad($len; $ch):
  (. + ($ch * $len))[:$len];
[
    .[]?
    | . + .chainDetails
    | select(.chainStatus == "ACTIVE"
        and .chainType == "evm"
        and (.rpcs | length) > 0
        and .nativeChainId)
    | {
        chainId: .nativeChainId,
        chainName: .chainName,
        rpc: (.rpcs // [])
        | reverse
        | max_by(.weight).url
    }
]
| sort_by(.chainId)
| .[] | (.chainId | tostring | rpad(11; " ")) + " = " + (.rpc | rpad(70; " ")) + " # " + .chainName
