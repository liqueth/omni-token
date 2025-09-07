# dvn.jq
# usage: jq --arg env $CHAIN_ENV --arg id $DVN_ID -f jq/dvn.jq config/nickmeta.json > config/$CHAIN_ENV/dvn/$DVN_ID.json
{
    env: $env,
    id: $id,
    keyValues: [
        .[]?
        | . +.chainDetails + ((.dvns // {}) | to_entries[])
        | select(.value.version == 2
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
