contract=$(jq -r '.transactions[].additionalContracts[].address' broadcast/OmniTokenProto.s.sol/$chain/run-latest.json)
args=$(cast abi-encode "constructor(address)" $(jq -r '.transactions[].arguments[0]' broadcast/OmniTokenProto.s.sol/$chain/run-latest.json))
forge verify-contract $contract OmniToken --constructor-args $args --chain $chain --verifier etherscan # --show-standard-json-input > io/$chain/verify.json
