# jq/deployments.jq
# usage: jq --arg env testnet -f jq/deployments.jq io/nickmeta.json > io/testnet/deployments.json
# usage: jq --arg env mainnet -f jq/deployments.jq io/nickmeta.json > io/mainnet/deployments.json
# usage: jq --arg env $env -f jq/deployments.jq io/nickmeta.json > io/$env/deployments.json
[
    .[]
    | . + .deployments[]? + .chainDetails
    | select(.version == 2
            and .environment == $env
            and .nativeChainId
            and .eid
            and .blockedMessageLib.address
            and .endpointV2.address
            and .executor.address
            and .sendUln302.address
            and .receiveUln302.address)
    | {
        blocker: .blockedMessageLib.address,
        chainId: .nativeChainId,
        eid: .eid | tonumber,
        endpoint: .endpointV2.address,
        executor: .executor.address,
        receiver: .receiveUln302.address,
        sender: .sendUln302.address,
    }
]
| group_by(.chainId)
| map(max_by(.eid))
| sort_by(.chainId)
