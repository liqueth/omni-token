// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ImmutableUintToUint.sol";

/**
 * @notice Deploy the ImmutableUintToUint protofactory contract.
 * @dev Usage: OUT=io/$CHAIN_ID/UintToUint.json forge script script/UintToUint.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
 */
contract UintToUint is Script {
    function run() external {
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(ImmutableUintToUint).creationCode));
        console.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            ImmutableUintToUint deployed = new ImmutableUintToUint{salt: 0x0}();
            vm.stopBroadcast();
            console.log("deployed: ", address(deployed));
        } else {
            console.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("OUT"));
    }
}
