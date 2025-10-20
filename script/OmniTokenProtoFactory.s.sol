// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OmniTokenProtoFactory.sol";

/// @notice Deploy the OmniTokenProtoFactory contract.
/// @dev Usage: factory=io/$chain/OmniTokenProtoFactory.json forge script script/OmniTokenProtoFactory.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
contract OmniTokenProtoFactoryCreate is Script {
    function run() external {
        console2.log("script   : OmniTokenProtoFactoryCreate");
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(OmniTokenProtoFactory).creationCode));
        console2.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            OmniTokenProtoFactory actual = new OmniTokenProtoFactory{salt: 0x0}();
            vm.stopBroadcast();
            console2.log("actual : ", address(actual));
        } else {
            console2.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("factory"));
    }
}
