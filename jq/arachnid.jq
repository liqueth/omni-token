# arachnid.jq
# usage: jq -Rf jq/arachnid.jq < config/arachnid.csv > config/arachnid.json
.
| split("\n")
| map(split(","))
| [
    .[]
    | select(.[4] == "present")
    | {
        url: .[0],
        chainId: .[1],
        key: .[3]
    }
]
| unique_by(.chainId)
