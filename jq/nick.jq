# nick.jq
# usage: jq -sRf jq/nick.jq < io/nick.csv > io/nick.json
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
