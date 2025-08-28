# config/EndpointConfig/endpoint.jq
{
    version: $version,
    chains: [
        .[]? as $c
        | select($c.environment == $env)
        | ($c.deployments // [])[]?
        | select(.version == $version)
        | $c.chainDetails.nativeChainId as $chainId
        | select($chainId != null and .eid != null
                 and .endpointV2?.address?
                 and .executor?.address?
                 and .sendUln302?.address?
                 and .receiveUln302?.address?)
        | {
            blockedMessageLib: .blockedMessageLib.address,
            chainId: $chainId,
            eid: (.eid | tonumber),
            endpoint: .endpointV2.address,
            executor: .executor.address,
            receiveLib: .receiveUln302.address,
            sendLib: .sendUln302.address
        }
        | select(all(.[]?; . != null))
    ]
    | group_by(.chainId)
    | map(max_by(.eid))        # keep the largest eid per chainId
    | sort_by(.chainId)        # numeric sort
}
