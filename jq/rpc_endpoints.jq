# config/rpc_endpoints.jq
# jq -rf jq/rpc_endpoints.jq config/arachnid.json > rpc_endpoints.toml
# jq -f jq/rpc_endpoints.jq config/active.json | jq -r '.[] | "\(.chainId) = \(.rpcs)"' | sed '1i[rpc_endpoints]' > rpc_endpoints.toml
def rpad($len; $ch):
  (. + ($ch * $len))[:$len];
.[]
| .
| (.chainId | tostring | rpad(11; " ")) + " = \"" + (.url + "\"" | rpad(70; " ")) + " # " + .key
