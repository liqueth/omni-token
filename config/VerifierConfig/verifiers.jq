# verifiers.jq
{
    version: $version,
    env: $env,
    dvns: [
        .[]?
        | . +.chainDetails + ((.dvns // {}) | to_entries[])
        | select(.value.version == $version
                and .chainStatus == "ACTIVE"
                and .environment == $env
                and .value.id
                and .nativeChainId)
        | {
            id: .value.id,
            canonicalName: .value.canonicalName
        }
    ]
    | sort_by(.id)
    | unique_by(.id, .canonicalName)
}
