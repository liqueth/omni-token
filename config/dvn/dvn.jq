# verifier.jq
{
    version: $version,
    id: $id,
    chains: [
        .[]?
        | . +.chainDetails + ((.dvns // {}) | to_entries[])
        | select(.value.version == $version
                and .chainStatus == "ACTIVE"
                and .environment == $env
                and .value.id == $id
                and .nativeChainId)
        | {
            chainId: .nativeChainId,
            dvn: .key
        }
    ]
    | sort_by(.chainId)
    | unique_by(.chainId)
}
