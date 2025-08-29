# config/EndpointConfig/endpoint.jq
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
            blocker: .blockedMessageLib.address,
            chainId: .nativeChainId,
            eid: .eid | tonumber,
            endpoint: .endpointV2.address,
            executor: .executor.address,
            receiver: .receiveUln302.address,
            sender: .sendUln302.address
        }
    ]
    | group_by(.chainId)
    | map(max_by(.eid))        # keep the largest eid per chainId
    | sort_by(.chainId)        # numeric sort
}
