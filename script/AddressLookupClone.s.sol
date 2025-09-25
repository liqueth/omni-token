// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AddressLookup.sol";

/// @notice Deploy an AddressLookup clone ONLY if it doesn't already exist (idempotent).
/// @dev Environment variables (required):
///   - proto : address of the IAddressLookupProto contract
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
        console2.log("script   : AddressLookupClone");

        address proto = abi.decode(vm.parseJson(vm.readFile(vm.envString("proto"))), (address));
        console2.log("proto    :", proto);

        Config memory config = abi.decode(vm.parseJson(vm.readFile(vm.envString("config"))), (Config));
        console2.log("id       :", config.id);
        console2.log("env      :", config.env);

        (address predicted,) = IAddressLookupProto(proto).cloneAddress(config.keyValues);
        console2.log("predicted:", predicted);

        string memory action = "reused";
        address actual = predicted;
        if (actual.code.length == 0) {
            vm.startBroadcast();
            (actual,) = IAddressLookupProto(proto).clone(config.keyValues);
            vm.stopBroadcast();
            action = "deployed";
        }

        console2.log("actual   :", actual);
        console2.log("action   :", action);

        vm.writeJson(vm.toString(actual), vm.envString("messaging"), string.concat(".", config.id));
    }
}
