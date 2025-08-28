{
    chains: [
    .[] as $c
    | select($c.environment == env.CHAIN_ENV)
    | $c.deployments[]
    | select(.version == 2)
    | {
      chainId: ($c.chainDetails.nativeChainId // $c.nativeChainId),
      eid: (.eid | tonumber),
      endpoint: .endpointV2.address,
      executor: .executor.address,
      sendLib: .sendUln302.address,
      receiveLib: .receiveUln302.address,
      blockedMessageLib: (.blockedMessageLib.address // null)
        }
    ]
}
