forge config --json \
| jq -r '.rpc_endpoints | to_entries[] | "\(.key) \(.value)"' \
| while read name url; do
  code=$(cast code 0x4e59b44847b379578588920cA78FbF26c0B4956C --rpc-url "$url" 2>/dev/null || true)
  if [ "$code" = "0x" ]; then
    echo "$name,none"
  elif [[ "$code" == 0x* ]]; then
    echo "$name,present"
  else
    echo "$name,error"
  fi
done
