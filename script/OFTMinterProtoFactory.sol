// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OFTMinterProtoFactory.sol";

/// @notice Deploy the OFTMinterProtoFactory contract.
/// @dev Usage: factory=io/$chain/OFTMinterProtoFactory.json forge script script/OFTMinterProtoFactory.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
contract OFTMinterProtoFactoryCreate is Script {
    function run() external {
        console2.log("script   : OmniTokenProtoFactoryCreate");
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(OFTMinterProtoFactory).creationCode));
        console2.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            OFTMinterProtoFactory actual = new OFTMinterProtoFactory{salt: 0x0}();
            vm.stopBroadcast();
            console2.log("actual : ", address(actual));
        } else {
            console2.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("factory"));
    }
}
