// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AddressLookup.sol";

/// @notice Deploy an AddressLookup clone ONLY if it doesn't already exist (idempotent).
/// @dev Environment variables (required):
///   - proto : address of the IAddressLookupCloner contract
///   - config  : path to JSON config file with { env, id, keyValues }
/// @dev Example:
///   proto=io/$CHAIN_ID/AddressLookupProto.json config=io/testnet/blocker.json messaging=io/$CHAIN_ID/messaging.json forge script script/AddressLookupClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
contract AddressLookupClone is Script {
    struct Config {
        string env;
        string id;
        AddressLookup.KeyValue[] keyValues;
    }

    function run() external {
        address proto = abi.decode(vm.parseJson(vm.readFile(vm.envString("proto"))), (address));
        console2.log("proto       :", proto);
        Config memory config = abi.decode(vm.parseJson(vm.readFile(vm.envString("config"))), (Config));

        // Resolve predicted clone address (pure/read-only)
        (address predicted,) = IAddressLookupCloner(proto).cloneAddress(config.keyValues);

        // Basic context logs (human-friendly)
        console2.log("predicted   :", predicted);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address clone = predicted;
        if (clone.code.length == 0) {
            vm.startBroadcast();
            (clone,) = IAddressLookupCloner(proto).clone(config.keyValues);
            vm.stopBroadcast();
            action = "deployed";
        }

        // Result logs
        console2.log("action    : ", action);
        console2.log("clone     : ", clone);
        console2.log("id        : ", config.id);
        console2.log("env       : ", config.env);

        vm.writeJson(vm.toString(clone), vm.envString("messaging"), string.concat(".", config.id));
    }
}
