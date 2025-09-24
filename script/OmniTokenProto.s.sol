// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OmniToken.sol";

/**
 * @title Deploy Script for OmniToken
 * @notice Deploys the OmniToken contract with specified configuration
 * @dev Usage: CONFIG=io/$CHAIN_ID/MessagingConfig.json PROTO=io/$CHAIN_ID/OmniTokenProto.json forge script script/OmniTokenProto.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast --verify --delay 10 --retries 10
 */
contract OmniTokenProto is Script {
    function run() external {
        address config = abi.decode(vm.parseJson(vm.readFile(vm.envString("CONFIG"))), (address));
        console2.log("config: ", config);
        bytes memory args = abi.encode(config);
        bytes memory initCode = abi.encodePacked(type(OmniToken).creationCode, args);
        address predicted = vm.computeCreate2Address(0x0, keccak256(initCode));
        console2.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            OmniToken token = new OmniToken{salt: 0x0}(IMessagingConfig(config));
            vm.stopBroadcast();
            console2.log("address: ", address(token));
        } else {
            console2.log("already deployed");
        }

        vm.writeJson(vm.toString(predicted), vm.envString("PROTO"));
    }
}
