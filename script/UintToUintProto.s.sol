// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ImmutableUintToUint.sol";

/// @notice Deploy the ImmutableUintToUint protofactory contract.
/// @dev Usage: proto=io/$CHAIN_ID/UintToUintProto.json forge script script/UintToUintProto.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
contract UintToUintProto is Script {
    function run() external {
        console2.log("script   : UintToUintProto");
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(ImmutableUintToUint).creationCode));
        console2.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            ImmutableUintToUint deployed = new ImmutableUintToUint{salt: 0x0}();
            vm.stopBroadcast();
            console2.log("deployed : ", address(deployed));
        } else {
            console2.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("proto"));
    }
}
