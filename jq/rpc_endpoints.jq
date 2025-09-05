# config/rpc_endpoints.jq
# jq -rf jq/rpc_endpoints.jq config/nick.json > rpc_endpoints.toml
def rpad($len; $ch):
  (. + ($ch * $len))[:$len];
.[]
| .
| (.chainId | tostring | rpad(11; " ")) + " = \"" + (.url + "\"" | rpad(70; " ")) + " # " + .key
