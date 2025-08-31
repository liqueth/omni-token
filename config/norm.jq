# config/norm.jq
[
    .[]?
    | . + .chainDetails
    | select(.chainStatus == "ACTIVE"
        and .chainType == "evm"
        and .nativeChainId)
    | {
        chainId: .nativeChainId,
        environment: .environment,
        chainDetails: .chainDetails,
        deployments: [.deployments[] | select(.version == 2)],
        dvns: [
            (.dvns // {})
            | to_entries[]
            | select(.value.version == $version and .value.deprecated != true)
            | {
                id: .value.id,
                dvn: .key
            }
        ]
        | sort_by(.id),
        rpcs: .rpcs
    }
    | select(.deployments | length == 1)
]
| sort_by(.chainId)
