// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ImmutableUintToAddress.sol";

/**
 * @notice Deploy the ImmutableUintToAddress protofactory contract.
 * @dev Usage: forge script script/UintToAddressProto.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
 */
contract UintToAddressProto is Script {
    function run() external {
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(ImmutableUintToAddress).creationCode));
        console.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            ImmutableUintToAddress deployed = new ImmutableUintToAddress{salt: 0x0}();
            vm.stopBroadcast();
            console.log("deployed: ", address(deployed));
        } else {
            console.log("already deployed");
        }

        string memory env = vm.envString("CHAIN_ENV");
        string memory jsonPath = string.concat("./config/", env, "/UintToAddressProto.json");
        vm.writeJson(vm.toString(predicted), jsonPath, ".UintToAddressProto");
    }
}
