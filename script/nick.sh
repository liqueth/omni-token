#!/bin/bash
# Find which chains have the arachnid deployer contract
# Usage: script/nick.sh < io/rpc.csv > io/nick.csv

while read line; do
  IFS=, read -r rpc rest <<< "$line"
  code=$(cast code 0x4e59b44847b379578588920cA78FbF26c0B4956C --rpc-url "$rpc" 2>/dev/null || true)
  if [ "$code" = "0x" ]; then
    status=none
  elif [[ "$code" == 0x* ]]; then
    status=present
  else
    status=error
  fi
  echo "$rpc,$rest,$status"
done
