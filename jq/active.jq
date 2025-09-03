# Usage: jq -f jq/active.jq config/metadata.json > config/active.json
[
    .[]?
    | select(.chainDetails.chainStatus == "ACTIVE"
        and .chainDetails.chainType == "evm"
        and .chainDetails.nativeChainId)
]
| sort_by(.chainDetails.nativeChainId)
| unique_by(.chainDetails.nativeChainId)

