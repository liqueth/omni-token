// SPDX-License-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ZKBridgeToken.sol";

contract Deploy is Script {
    function run() external {
        address zkBridgeAddr = 0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7; // Testnet zkBridge
        bytes32 salt = 0x0; // Same salt for all chains

        // Define supported chain configs (e.g., Sepolia with mint, BSC Testnet with 0 mint)
        ZKBridgeToken.ChainConfig[] memory chainConfigs = new ZKBridgeToken.ChainConfig[](3);
        chainConfigs[0] = ZKBridgeToken.ChainConfig(11155111, 119, 3_000_000 * 10 ** 18); // Ethereum Testnest
        chainConfigs[1] = ZKBridgeToken.ChainConfig(97, 103, 2_000_000 * 10 ** 18); // BSC Testnet
        chainConfigs[2] = ZKBridgeToken.ChainConfig(18880, 131, 1_000_000 * 10 ** 18); // EXPchain Testnet

        vm.startBroadcast();

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
