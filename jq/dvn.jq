# dvn.jq
# usage:
{
    env: $env,
    id: $id,
    keyValues: [
        .[]?
        | . +.chainDetails + ((.dvns // {}) | to_entries[])
        | select(.value.version == $version
                and .environment == $env
                and .value.id == $id
                and .nativeChainId)
        | {
            key: .nativeChainId,
            value: .key
        }
    ]
    | sort_by(.key)
    | unique_by(.key)
}
