# dvns_by_chain.jq
# Find the DVNs (Distribute Verifier Networks) for each chain.
# Usage: jq --arg env $env -r -f jq/dvns_by_chain.jq io/nickmeta.json > io/$env/dvns_by_chain.json
[
    .[]
    | select(.environment == $env)
    | {
        chainId: .chainDetails.nativeChainId,
        dvns: (.dvns // {})
        | to_entries
        | [
            .[]
            | .value.id
        ]
        | sort_by(.)
    }
]
#| sort_by(.chainId)
