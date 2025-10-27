// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OmniTokenBridgedFactory.sol";

/// @notice Deploy the OmniTokenBridgedFactory contract.
/// @dev Usage: factory=io/$chain/OmniTokenBridgedFactory.json forge script script/OmniTokenBridgedFactory.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
contract OmniTokenBridgedFactoryCreate is Script {
    function run() external {
        console2.log("script   : OmniTokenBridgedFactoryCreate");
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(OmniTokenBridgedFactory).creationCode));
        console2.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            OmniTokenBridgedFactory actual = new OmniTokenBridgedFactory{salt: 0x0}();
            vm.stopBroadcast();
            console2.log("actual : ", address(actual));
        } else {
            console2.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("factory"));
    }
}
