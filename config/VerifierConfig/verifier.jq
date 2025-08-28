# config/VerifierConfig/verifier.jq
{
    id: $id,
    chains: (
        [
            .[]? as $c
            | select(($env // "") == "" or $c.environment == $env)
            | ($c.dvns // {})                           # dvns are on the chain object
              | to_entries[]                            # {key: <address>, value: {id, version, ...}}
            | select(.value.version == 2 and .value.id == $id)
            | {
                chainId: ($c.chainDetails.nativeChainId // $c.nativeChainId),
                address: .key
            }
        ]
        | unique_by(.chainId)
        | sort_by(.chainId)
    )
}
