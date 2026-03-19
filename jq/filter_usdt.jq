# Extract only USDT tokens from nickmeta.json with flat output schema
# Usage: jq -f filter_usdt.jq nickmeta.json > nickmeta_usdt.json
[
  .[] |
  (.chainDetails.nativeChainId // null) as $chainId |
  .chainName as $chainName |
  (.blockExplorers[0].url // null) as $blockExplorer |
  (.tokens // {}) | to_entries[] |
  select(.value.symbol == "USDT") |
  {
    chainId: $chainId,
    chainName: $chainName,
    address: .key,
    symbol: .value.symbol,
    name: .value.name,
    type: .value.type,
    erc20TokenAddress: .value.erc20TokenAddress,
    peggedTo: .value.peggedTo,
    blockExplorer: $blockExplorer
  }
]
