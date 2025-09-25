# dvns.jq
# Usage: jq --arg env $env -r -f jq/dvns.jq io/nickmeta.json > io/$env/dvns.txt
[
.[]
| select(.environment == $env)
| (.dvns // {})
| to_entries[]
| .value.id
| select(.)
]
| sort_by(.)
| unique_by(.)
| .[]
