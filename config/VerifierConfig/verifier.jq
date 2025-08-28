# verifier-tuples.jq
{
    id: $id,
    chains: (
        [
            .[]? as $c
            | select(($env // "") == "" or $c.environment == $env)
            | ($c.dvns // {}) | to_entries[]
            | select(.value.version == 2 and .value.id == $id)
            | [
                ($c.chainDetails.nativeChainId | tonumber),
                .key
              ]
        ]
        | sort_by(.[0])    # numeric sort by chainId
        | unique_by(.[0])  # drop dups by chainId
    )
}
