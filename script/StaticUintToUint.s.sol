// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/StaticUintToUint.sol";

/**
 * @notice Deploy the OmniAddress factory/implementation contract.
 * @dev Usage: forge script script/StaticUintToUint.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify --delay 10 --retries 10
 */
contract StaticUintToUintDeploy is Script {
    function run() external {
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(StaticUintToUint).creationCode));
        console.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            StaticUintToUint deployed = new StaticUintToUint{salt: 0x0}();
            vm.stopBroadcast();
            console.log("deployed: ", address(deployed));
        } else {
            console.log("already deployed");
        }

        string memory env = vm.envString("CHAIN_ENV");
        string memory jsonPath = string.concat("./config/", env, "/addresses.json");
        vm.writeJson(vm.toString(predicted), jsonPath, ".StaticUintToUint");
    }
}
