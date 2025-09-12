// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/OmniToken.sol";

/**
 * @title Deploy Script for OmniToken
 * @notice Deploys the OmniToken contract with specified configuration
 * @dev Usage: forge script script/OmniToken.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify --delay 10 --retries 10
 */
contract OmniTokenDeploy is Script {
    function run() external {
        address cfg = vm.envAddress("MessagingConfig");
        bytes memory args = abi.encode(cfg);
        bytes memory initCode = abi.encodePacked(type(OmniToken).creationCode, args);

        address predicted = vm.computeCreate2Address(0x0, keccak256(initCode));
        console.log("predicted: ", predicted);
        if (predicted.code.length == 0) {
            vm.startBroadcast();
            OmniToken token = new OmniToken{salt: 0x0}(IMessagingConfig(cfg));
            vm.stopBroadcast();
            console.log("address: ", address(token));
        } else {
            console.log("already deployed");
        }

        string memory env = vm.envString("CHAIN_ENV");
        string memory jsonPath = string.concat("./config/", env, "/OmniToken.json");
        vm.writeJson(vm.toString(predicted), jsonPath, ".OmniToken");
    }
}
