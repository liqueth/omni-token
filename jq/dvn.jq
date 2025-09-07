# dvn.jq
# usage: jq --arg id $DVN_ID --arg env $CHAIN_ENV --argjson version 2 -f jq/dvn.jq config/nickmeta.json > config/$CHAIN_ENV/$DVN_ID.json
{
    version: $version,
    env: $env,
    id: $id,
    map: [
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
