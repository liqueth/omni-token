contract=$(jq -r '.transactions[].additionalContracts[0].address' broadcast/OmniTokenBridgedProto.s.sol/$chain/run-latest.json)
args=$(cast abi-encode \
  "constructor((address,uint[][],string,address,uint128,string,address),address)" \
  "$(jq -r '.transactions[0].arguments[0]' broadcast/OmniTokenBridgedProto.s.sol/$chain/run-latest.json)" \
  "$(jq -r '.transactions[0].arguments[1]' broadcast/OmniTokenBridgedProto.s.sol/$chain/run-latest.json)" \
)
forge verify-contract $contract OmniTokenBridged --constructor-args $args --chain $chain --verifier etherscan # --show-standard-json-input > io/$chain/verify.json
