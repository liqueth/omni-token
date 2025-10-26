contract=$(jq -r '.transactions[].additionalContracts[].address' broadcast/BridgeProto.s.sol/$chain/run-latest.json)
args=$(cast abi-encode "constructor(address)" $(jq -r '.transactions[].arguments[0]' broadcast/BridgeProto.s.sol/$chain/run-latest.json))
forge verify-contract $contract Bridge --constructor-args $args --chain $chain --verifier etherscan # --show-standard-json-input > io/$chain/verify.json
