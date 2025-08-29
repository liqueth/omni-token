# verifier.jq
{
    version: $version,
    id: $id,
    chains: (
        [
            .[]? as $c
            | select($c.environment == $env)
            | ($c.dvns // {}) | to_entries[]
            | $c.chainDetails.nativeChainId as $chainId
            | $c.chainDetails.chainStatus as $chainStatus
            | select(.value.version == $version
                    and $chainStatus != "DEPRECATED"
                    and .value.id == $id
                    and $chainId)
            | {
                chainId: $chainId,
                dvn: .key
            }
        ]
        | sort_by(.chainId)     # numeric sort
        | unique_by(.chainId)   # drop dups
    )
}
