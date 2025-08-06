// SPDX-License-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ZKBridgeToken.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address zkBridgeAddr = 0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7; // Testnet zkBridge
        bytes32 salt = bytes32(uint256(1234)); // Same salt for all chains

        // Define supported chain configs (e.g., Sepolia with mint, BSC Testnet with 0 mint)
        ZKBridgeToken.ChainConfig[] memory chainConfigs = new ZKBridgeToken.ChainConfig[](2);
        chainConfigs[0] = ZKBridgeToken.ChainConfig(11155111, 119, 1_000_000 * 10 ** 18); // Sepolia, full mint
        chainConfigs[1] = ZKBridgeToken.ChainConfig(97, 103, 0); // BSC Testnet, no mint

        vm.startBroadcast(deployerPrivateKey);

        ZKBridgeToken token = new ZKBridgeToken{salt: salt}(
            "ZKBridgeToken",
            "ZBT",
            msg.sender, // allocTo
            zkBridgeAddr,
            chainConfigs
        );

        token;

        vm.stopBroadcast();
    }
}
