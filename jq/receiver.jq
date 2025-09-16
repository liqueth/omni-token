# receiver.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/receiver.jq io/$CHAIN_ENV/deployments.json > io/$CHAIN_ENV/receiver.json
{
    env: $env,
    id: "receiver",
    keyValues: [
        .[]
        | {
            key: .chainId,
            value: .receiver
        }
    ]
}
