// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OmniToken.sol";

/// @title Deploy Script for OmniToken
/// @notice Deploys the OmniToken contract with specified configuration
/// @dev Usage: config=io/$chain/MessagingConfig.json proto=io/$chain/OmniTokenProto.json forge script script/OmniTokenProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
contract OmniTokenProto is Script {
    function run() external {
        console2.log("script   : OmniTokenProto");
        address config = abi.decode(vm.parseJson(vm.readFile(vm.envString("config"))), (address));
        console2.log("config   : ", config);
        bytes memory args = abi.encode(config);
        bytes memory initCode = abi.encodePacked(type(OmniToken).creationCode, args);
        address predicted = vm.computeCreate2Address(0x0, keccak256(initCode));
        console2.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            OmniToken actual = new OmniToken{salt: 0x0}(IMessagingConfig(config));
            vm.stopBroadcast();
            console2.log("actual   : ", address(actual));
        } else {
            console2.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("proto"));
    }
}
