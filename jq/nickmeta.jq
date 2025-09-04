# Usage: jq -sf jq/nickmeta.jq config/active.json config/arachnid.json > config/nickmeta.json
(.[1] | map({(.key): true}) | add) as $wl
#| $wl
| .[0]
| .[]
| select($wl[(.chainKey)])
