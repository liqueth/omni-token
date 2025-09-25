// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IOmniTokenProto.sol";

/// @notice Deploy an OmniToken clone if it doesn't exist (idempotent).
/// @dev Environment variables (required):
///   - proto  : address of the IOmniTokenProto contract
///   - config : path to JSON config file with { mints, name, owner, symbol }
///   - clone  : path to JSON file that will contain the deployed address
/// @dev Example:
/// proto=io/$chain/OmniTokenProto.json config=io/testnet/OMNI_ALPHA.json clone=io/$chain/OMNI_ALPHA.json forge script script/OmniTokenClone.s.sol -f $chain --private-key $tx_key --broadcast
contract OmniTokenClone is Script {
    function run() external {
        console2.log("script   : OmniTokenClone");
        address proto = abi.decode(vm.parseJson(vm.readFile(vm.envString("proto"))), (address));
        console2.log("proto    :", proto);
        IOmniTokenProto.Config memory config =
            abi.decode(vm.parseJson(vm.readFile(vm.envString("config"))), (IOmniTokenProto.Config));
        console2.log("symbol   :", config.symbol);
        (address predicted,) = IOmniTokenProto(proto).cloneAddress(config);
        console2.log("predicted:", predicted);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address actual = predicted;
        if (actual.code.length == 0) {
            vm.startBroadcast();
            (actual,) = IOmniTokenProto(proto).clone(config);
            vm.stopBroadcast();
            action = "deployed";
        }

        // Result logs
        console2.log("actual   :", actual);
        console2.log("action   :", action);

        vm.writeJson(vm.toString(actual), vm.envString("clone"));
    }
}
