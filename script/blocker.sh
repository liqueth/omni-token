cast send --private-key $DEPLOYER_KEY --rpc-url $CHAIN_ID $OmniAddress "clone((uint256,address)[])" "$(jq -c . config/blocker-$CHAIN_ENV.json)"
