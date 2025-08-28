# verifier-structs.jq
{
    id: $id,
    chains: (
        [
            .[]? as $c
            | select(($env // "") == "" or $c.environment == $env)
            | ($c.dvns // {}) | to_entries[]
            | select(.value.version == $version and .value.id == $id)
            | {
                chainId: ($c.chainDetails.nativeChainId | tonumber),
                dvn: .key
            }
        ]
        | sort_by(.chainId)     # numeric sort
        | unique_by(.chainId)   # drop dups
    )
}
