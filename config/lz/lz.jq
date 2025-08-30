# config/lz/lz.jq
{
    version: $version,
    chains: [
        .[]?
        | . + .deployments[]? + .chainDetails
        | select(.version == $version
                and .chainStatus == "ACTIVE"
                and .environment == $env
                and .nativeChainId
                and .eid
                and .blockedMessageLib.address
                and .endpointV2.address
                and .executor.address
                and .sendUln302.address
                and .receiveUln302.address)
        | {
            chainId: .nativeChainId,
            eid: .eid | tonumber,
            blocker: .blockedMessageLib.address,
            endpoint: .endpointV2.address,
            executor: .executor.address,
            receiver: .receiveUln302.address,
            sender: .sendUln302.address,
            dvns: [
                (.dvns // {})
                | to_entries[]
                | select(.value.version == $version and .value.deprecated != true)
                | {
                    id: .value.id,
                    dvn: .key
                }
            ]
            | sort_by(.id)
        }
    ]
    | group_by(.chainId)
    | map(max_by(.eid))
    | sort_by(.chainId)
}
