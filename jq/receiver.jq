# receiver.jq
# Usage: jq --arg env $CHAIN_ENV -f jq/receiver.jq config/$CHAIN_ENV/deployments.json > config/$CHAIN_ENV/receiver.json
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
