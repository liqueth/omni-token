# config/EndpointConfig/endpoint.jq
{
    version: $version,
    chains: [
        .[]? as $c
        | select($c.environment == $env)
        | $c.deployments[]?
        | select(.version == $version) + $c.chainDetails
        | select(.nativeChainId != null
                and .chainStatus != "DEPRECATED"
                and .eid != null
                and .blockedMessageLib.address
                and .endpointV2?.address?
                and .executor?.address?
                and .sendUln302?.address?
                and .receiveUln302?.address?)
        | {
            blockedMessageLib: .blockedMessageLib.address,
            chainId: .nativeChainId,
            eid: (.eid | tonumber),
            endpoint: .endpointV2.address,
            executor: .executor.address,
            receiveLib: .receiveUln302.address,
            sendLib: .sendUln302.address
        }
    ]
    | group_by(.chainId)
    | map(max_by(.eid))        # keep the largest eid per chainId
    | sort_by(.chainId)        # numeric sort
}
