// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IUintToUintProto.sol";

/**
 * @title AddressLookupClone
 * @notice Deploy an AddressLookup clone ONLY if it doesn't already exist (idempotent).
 *
 * @dev Environment variables (required):
 *   - proto : address of the IAddressLookupCloner contract
 *   - config  : path to JSON config file with { env, id, keyValues }
 *
 * @dev Example:
 * proto=io/$CHAIN_ID/UintToUintProto.json config=io/testnet/endpointMapper.json clone=io/$CHAIN_ID/messaging.json forge script script/UintToUintClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
 */
contract UintToUintClone is Script {
    struct Config {
        string env;
        string id;
        IUintToUint.KeyValue[] keyValues;
    }

    function run() external {
        address cloner = abi.decode(vm.parseJson(vm.readFile(vm.envString("CLN"))), (address));
        console2.log("cloner     :", cloner);

        Config memory config = abi.decode(vm.parseJson(vm.readFile(vm.envString("config"))), (Config));
        (address predicted,) = IUintToUintProto(cloner).cloneAddress(config.keyValues);
        console2.log("predicted   :", predicted);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address clone = predicted;
        if (clone.code.length == 0) {
            vm.startBroadcast();
            (clone,) = IUintToUintProto(cloner).clone(config.keyValues);
            vm.stopBroadcast();
            action = "deployed";
        }

        // Result logs
        console2.log("action     :", action);
        console2.log("address    :", clone);
        console2.log("id         :", config.id);
        console2.log("env        :", config.env);

        vm.writeJson(vm.toString(clone), vm.envString("clone"), string.concat(".", config.id));
    }
}
