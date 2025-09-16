# Usage: jq -sf jq/nickmeta.jq io/active.json io/nick.json > io/nickmeta.json
(.[1] | map({(.key): true}) | add) as $wl
#| $wl
| [
    .[0]
    | .[]
    | select($wl[(.chainKey)])
]
