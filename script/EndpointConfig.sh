#!/bin/bash

# Deploy the token factory/implementation
forge script script/EndpointConfig.s.sol --sig "run(string)" config/endpoint/testnet.json --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast

# Save contract address displayed in commands above in environment variable
export EndpointConfigAddress=$(jq -r '.transactions[0].contractAddress' broadcast/EndpointConfig.s.sol/$CHAIN_ID/run-latest.json); echo $EndpointConfigAddress

export EndpointConfigArgs=$(cast abi-encode 'constructor(((address,uint256,uint32,address,address,address,address)[],uint256))' $(jq -r '.transactions[0].arguments[]' broadcast/EndpointConfig.s.sol/$CHAIN_ID/run-latest.json | tr -d ' ' | xargs))

forge verify-contract -q --chain $CHAIN_ID --rpc-url $CHAIN_ID --etherscan-api-key $ETHERSCAN_KEY --constructor-args $EndpointConfigArgs $EndpointConfigAddress src/EndpointConfig.sol:EndpointConfig
