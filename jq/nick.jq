# nick.jq
# usage: jq -Rf jq/nick.jq < config/nick.csv > config/nick.json
.
| split("\n")
| map(split(","))
| [
    .[]
    | select(.[4] == "present")
    | {
        url: .[0],
        chainId: .[1] | tonumber,
        rank: .[2],
        key: .[3]
    }
]
| unique_by(.chainId)
