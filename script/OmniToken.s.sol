// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/OmniToken.sol";

/**
 * @title Deploy Script for OmniToken
 * @notice Deploys the OmniToken contract with specified configuration
 */
contract OmniTokenDeploy is Script {
    function run() external {
        IMessagingConfig appConfig = IMessagingConfig(vm.envAddress("EndpointConfig"));
        bytes32 salt = 0x0;
        vm.startBroadcast();
        OmniToken token = new OmniToken{salt: salt}(appConfig);
        vm.stopBroadcast();
        console.log("address: ", address(token));
    }
}
