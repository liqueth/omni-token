# dvns.jq
# Usage: jq --arg env $CHAIN_ENV -r -f jq/dvns.jq io/nickmeta.json > io/$CHAIN_ENV/dvns.txt
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
