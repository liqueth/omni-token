// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AddressLookup.sol";

/// @notice Deploy the AddressLookup factory/implementation contract.
/// @dev Usage: proto=io/$CHAIN_ID/AddressLookupProto.json forge script script/AddressLookupProto.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
contract AddressLookupProto is Script {
    function run() external {
        console2.log("script   : AddressLookupProto");
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(AddressLookup).creationCode));
        console2.log("predicted:", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            AddressLookup actual = new AddressLookup{salt: 0x0}();
            vm.stopBroadcast();
            console2.log("actual   :", address(actual));
        } else {
            console2.log("already deployed");
        }

        string memory jsonPath = vm.envString("proto");
        vm.writeJson(vm.toString(predicted), jsonPath);
    }
}
