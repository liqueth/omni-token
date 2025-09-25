// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MessagingConfig.sol";

/// @notice Deploy the AddressLookup factory/implementation contract.
/// @dev Usage: IN=io/$CHAIN_ID/messaging.json OUT=io/$CHAIN_ID/MessagingConfig.json forge script script/MessagingConfig.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
contract MessagingConfigDeploy is Script {
    function run() external {
        IMessagingConfig.Struct memory cfg =
            abi.decode(vm.parseJson(vm.readFile(vm.envString("IN"))), (IMessagingConfig.Struct));
        bytes memory args = abi.encode(cfg);
        bytes memory initCode = abi.encodePacked(type(MessagingConfig).creationCode, args);

        address predicted = vm.computeCreate2Address(0x0, keccak256(initCode));
        console2.log("predicted:", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            MessagingConfig deployed = new MessagingConfig{salt: 0x0}(cfg);
            vm.stopBroadcast();
            console2.log("deployed:", address(deployed));
        } else {
            console2.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("OUT"));
    }
}
