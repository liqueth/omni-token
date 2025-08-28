{
    chains: [
        .[] as $c
        | select($c.environment == env.CHAIN_ENV)
        | $c.deployments[]
        | select(.version == 2)
        | {
            blockedMessageLib: .blockedMessageLib.address,
            chainId: $c.chainDetails.nativeChainId,
            eid: (.eid | tonumber),
            endpoint: .endpointV2.address,
            executor: .executor.address,
            receiveLib: .receiveUln302.address,
            sendLib: .sendUln302.address
        }
    ]
}
