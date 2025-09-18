// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IOmniTokenCloner.sol";

/**
 * @notice Deploy an OmniToken clone if it doesn't exist (idempotent).
 *
 * @dev Environment variables (required):
 *   - CLN : address of the IOmniTokenCloner contract
 *   - IN  : path to JSON config file with { mints, name, owner, symbol }
 *
 * @dev Example:
 * OmniTokenPath=config/OMNI_ALPHA.json forge script script/OmniTokenClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
 *   CLN=io/$CHAIN_ID/OmniToken.json IN=io/testnet/OMNI_ALPHA.json OUT=io/$CHAIN_ID/OmniTokens.json forge script script/OmniTokenClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
 */
contract OmniTokenClone is Script {
    function run() external {
        address cloner = abi.decode(vm.parseJson(vm.readFile(vm.envString("CLN"))), (address));
        console2.log("cloner     :", cloner);
        IOmniTokenCloner.Config memory cfg =
            abi.decode(vm.parseJson(vm.readFile(vm.envString("IN"))), (IOmniTokenCloner.Config));
        (address predicted,) = IOmniTokenCloner(cloner).cloneAddress(cfg);
        console2.log("predicted   :", predicted);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address clone = predicted;
        if (clone.code.length == 0) {
            vm.startBroadcast();
            (clone,) = IOmniTokenCloner(cloner).clone(cfg);
            vm.stopBroadcast();
            action = "deployed";
        }

        // Result logs
        console2.log("action     :", action);
        console2.log("address    :", clone);
        console2.log("symbol     :", cfg.symbol);

        vm.writeJson(vm.toString(clone), vm.envString("OUT"), string.concat(".", cfg.symbol));
    }
}
