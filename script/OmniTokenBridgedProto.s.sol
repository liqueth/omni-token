// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IOmniTokenBridgedFactory.sol";
import "../src/interfaces/IMessagingConfig.sol";
import "../src/interfaces/IOFTProto.sol";

/// @title Deploy Script for OmniToken
/// @notice Deploys the OmniToken contract with specified configuration
/// @dev Usage: factory=io/$chain/OmniTokenBridgedFactory.json config=io/$env/OMNIB.json bridge=io/$chain/BridgeProto.json proto=io/$chain/OmniTokenBridgedProto.json forge script script/OmniTokenBridgedProto.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
contract OmniTokenBridgedProto is Script {
    function run() external {
        console2.log("script   : OmniTokenBridgedProto");
        address factory = abi.decode(vm.parseJson(vm.readFile(vm.envString("factory"))), (address));
        console2.log("factory  : ", factory);
        address bridge = abi.decode(vm.parseJson(vm.readFile(vm.envString("bridge"))), (address));
        console2.log("bridge   : ", bridge);
        IOFTProto.Config memory config =
            abi.decode(vm.parseJson(vm.readFile(vm.envString("config"))), (IOFTProto.Config));
        console2.log("symbol   :", config.symbol);
        address predicted = IOmniTokenBridgedFactory(factory).createAddress(config, IOFTProto(bridge));
        console2.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            address actual = IOmniTokenBridgedFactory(factory).create(config, IOFTProto(bridge));
            vm.stopBroadcast();
            console2.log("actual   : ", address(actual));
        } else {
            console2.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("proto"));
    }
}
