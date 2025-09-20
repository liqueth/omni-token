// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OmniAddress.sol";

/**
 * @title OmniAddressClone
 * @notice Deploy an OmniAddress clone ONLY if it doesn't already exist (idempotent).
 *
 * @dev Environment variables (required):
 *   - CLN : address of the IOmniAddressCloner contract
 *   - IN  : path to JSON config file with { env, id, keyValues }
 *
 * @dev Example:
 *   CLN=io/$CHAIN_ID/OmniAddress.json IN=io/testnet/blocker.json OUT=io/$CHAIN_ID/messaging.json forge script script/OmniAddressClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
 */
contract OmniAddressClone is Script {
    struct Config {
        string env;
        string id;
        OmniAddress.KeyValue[] keyValues;
    }

    function run() external {
        address cloner = abi.decode(vm.parseJson(vm.readFile(vm.envString("CLN"))), (address));
        console2.log("cloner     :", cloner);
        Config memory cfg = abi.decode(vm.parseJson(vm.readFile(vm.envString("IN"))), (Config));

        // Resolve predicted clone address (pure/read-only)
        (address predicted,) = IOmniAddressCloner(cloner).cloneAddress(cfg.keyValues);

        // Basic context logs (human-friendly)
        console2.log("predicted   :", predicted);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address clone = predicted;
        if (clone.code.length == 0) {
            vm.startBroadcast();
            (clone,) = IOmniAddressCloner(cloner).clone(cfg.keyValues);
            vm.stopBroadcast();
            action = "deployed";
        }

        // Result logs
        console2.log("action     :", action);
        console2.log("address    :", clone);
        console2.log("id         :", cfg.id);
        console2.log("env        :", cfg.env);

        vm.writeJson(vm.toString(clone), vm.envString("OUT"), string.concat(".", cfg.id));
    }
}
