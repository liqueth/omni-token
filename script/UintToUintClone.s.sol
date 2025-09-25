// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IUintToUintProto.sol";

/// @notice Deploy an AddressLookup clone ONLY if it doesn't already exist (idempotent).
/// @dev Environment variables (required):
///   - proto : address of the IAddressLookupProto contract
///   - config  : path to JSON config file with { env, id, keyValues }
/// @dev Example:
/// proto=io/$CHAIN_ID/UintToUintProto.json config=io/testnet/endpointMapper.json clone=io/$CHAIN_ID/messaging.json forge script script/UintToUintClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
contract UintToUintClone is Script {
    struct Config {
        string env;
        string id;
        IUintToUint.KeyValue[] keyValues;
    }

    function run() external {
        console2.log("== UintToUintClone ==");
        address proto = abi.decode(vm.parseJson(vm.readFile(vm.envString("proto"))), (address));
        console2.log("proto     :", proto);

        Config memory config = abi.decode(vm.parseJson(vm.readFile(vm.envString("config"))), (Config));
        console2.log("id        :", config.id);
        console2.log("env       :", config.env);

        (address predicted,) = IUintToUintProto(proto).cloneAddress(config.keyValues);
        console2.log("predicted :", predicted);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address clone = predicted;
        if (clone.code.length == 0) {
            vm.startBroadcast();
            (clone,) = IUintToUintProto(proto).clone(config.keyValues);
            vm.stopBroadcast();
            action = "deployed";
        }

        // Result logs
        console2.log("action    :", action);
        console2.log("clone     :", clone);

        vm.writeJson(vm.toString(clone), vm.envString("clone"), string.concat(".", config.id));
    }
}
