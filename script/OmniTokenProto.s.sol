// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IOmniTokenProtoFactory.sol";
import "../src/interfaces/IMessagingConfig.sol";

/// @title Deploy Script for OmniToken
/// @notice Deploys the OmniToken contract with specified configuration
/// @dev Usage: factory=io/$chain/OmniTokenProtoFactory.json config=io/$chain/MessagingConfig.json proto=io/$chain/OmniTokenProto.json forge script script/OmniTokenProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
contract OmniTokenProto is Script {
    function run() external {
        console2.log("script   : OmniTokenProto");
        address factory = abi.decode(vm.parseJson(vm.readFile(vm.envString("factory"))), (address));
        console2.log("factory  : ", factory);
        address config = abi.decode(vm.parseJson(vm.readFile(vm.envString("config"))), (address));
        console2.log("config   : ", config);
        address predicted = IOmniTokenProtoFactory(factory).createAddress(IMessagingConfig(config));
        console2.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            address actual = IOmniTokenProtoFactory(factory).create(IMessagingConfig(config));
            vm.stopBroadcast();
            console2.log("actual   : ", address(actual));
        } else {
            console2.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("proto"));
    }
}
