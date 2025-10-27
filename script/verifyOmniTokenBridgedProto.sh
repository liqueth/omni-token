contract=$(jq -r '.transactions[].additionalContracts[].address' broadcast/OmniTokenBridgedProto.s.sol/$chain/run-latest.json)
args=$(cast abi-encode "constructor(address,address)" $(jq -r '.transactions[0].arguments[0], .transactions[0].arguments[1]' broadcast/OmniTokenBridgedProto.s.sol/$chain/run-latest.json))
forge verify-contract $contract OmniTokenBridged --constructor-args $args --chain $chain --verifier etherscan # --show-standard-json-input > io/$chain/verify.json
