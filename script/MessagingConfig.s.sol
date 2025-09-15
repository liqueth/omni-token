// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MessagingConfig.sol";

/**
 * @notice Deploy the OmniAddress factory/implementation contract.
 * @dev Usage: MessagingConfigPath=config/testnet/messaging.json forge script script/MessagingConfig.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_API_KEY --broadcast --verify --delay 10 --retries 10
 */
contract MessagingConfigDeploy is Script {
    function run() external {
        string memory path = vm.envString("MessagingConfigPath");
        bytes memory raw = vm.parseJson(vm.readFile(path));
        IMessagingConfig.Struct memory cfg = abi.decode(raw, (IMessagingConfig.Struct));
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

        string memory env = vm.envString("CHAIN_ENV");
        string memory jsonPath = string.concat("./config/", env, "/MessagingConfig.json");
        vm.writeJson(vm.toString(predicted), jsonPath, ".MessagingConfig");
    }
}
