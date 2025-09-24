// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AddressLookup.sol";

/**
 * @notice Deploy the AddressLookup factory/implementation contract.
 * @dev Usage: OUT=io/$CHAIN_ID/AddressLookup.json forge script script/AddressLookup.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
 */
contract AddressLookupScript is Script {
    function run() external {
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(AddressLookup).creationCode));
        console2.log("predicted:", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            AddressLookup deployed = new AddressLookup{salt: 0x0}();
            vm.stopBroadcast();
            console2.log("deployed:", address(deployed));
        } else {
            console2.log("already deployed");
        }

        string memory jsonPath = vm.envString("OUT");
        vm.writeJson(vm.toString(predicted), jsonPath);
    }
}
