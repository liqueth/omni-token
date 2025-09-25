// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IOmniTokenProto.sol";

/// @notice Deploy an OmniToken clone if it doesn't exist (idempotent).
/// @dev Environment variables (required):
///   - PROTO : address of the IOmniTokenProto contract
///   - CONFIG  : path to JSON config file with { mints, name, owner, symbol }
/// @dev Example:
/// PROTO=io/$CHAIN_ID/OmniTokenProto.json CONFIG=io/testnet/OMNI_ALPHA.json CLONE=io/$CHAIN_ID/OMNI_ALPHA.json forge script script/OmniTokenClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
contract OmniTokenClone is Script {
    function run() external {
        address cloner = abi.decode(vm.parseJson(vm.readFile(vm.envString("PROTO"))), (address));
        console2.log("cloner     :", cloner);
        IOmniTokenProto.Config memory config =
            abi.decode(vm.parseJson(vm.readFile(vm.envString("CONFIG"))), (IOmniTokenProto.Config));
        (address predicted,) = IOmniTokenProto(cloner).cloneAddress(config);
        console2.log("predicted   :", predicted);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address clone = predicted;
        if (clone.code.length == 0) {
            vm.startBroadcast();
            (clone,) = IOmniTokenProto(cloner).clone(config);
            vm.stopBroadcast();
            action = "deployed";
        }

        // Result logs
        console2.log("action     :", action);
        console2.log("address    :", clone);
        console2.log("symbol     :", config.symbol);

        vm.writeJson(vm.toString(clone), vm.envString("CLONE"));
    }
}
