# Filters LayerZero API metadata downloaded from https://metadata.layerzero-api.com/v1/metadata
# to retain active EVM chain objects with valid nativeChainId, sorted and deduplicated by chain ID.
# Usage: jq -f jq/active.jq config/metadata.json > config/active.json
[
    .[]?
    | select(.chainDetails.chainStatus == "ACTIVE"
        and .chainDetails.chainType == "evm"
        and .chainDetails.nativeChainId)
]
| sort_by(.chainDetails.nativeChainId)
| unique_by(.chainDetails.nativeChainId)
