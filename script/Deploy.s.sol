// SPDX-License-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "../src/ZKBridgeToken.sol";

/**
 * @title Deploy Script for ZKBridgeToken
 * @notice Deploys the ZKBridgeToken contract with specified configurations
 *         The deployer account will receive the initial mint amounts across specified chains.
 */
contract Deploy is Script {
    using stdJson for string;

    struct Config {
        ZKBridgeToken.ChainConfig[] chains;
        string name;
        string symbol;
        address zkBridge;
    }

    function run() external {
        string memory path = vm.envString("CONFIG");
        string memory json = vm.readFile(path);
        bytes memory encodedData = vm.parseJson(json);

        Config memory config = abi.decode(encodedData, (Config));
        console.log("chains: ", config.chains.length);
        for (uint256 i = 0; i < config.chains.length; i++) {
            ZKBridgeToken.ChainConfig memory chainConfig = config.chains[i];
            console.log("evmChain: ", chainConfig.evmChain);
            console.log("mintAmount: ", chainConfig.mintAmount);
            console.log("name: ", chainConfig.name);
            console.log("zkChain: ", chainConfig.zkChain);
        }

        bytes32 salt = 0x0;

        vm.startBroadcast();

        ZKBridgeToken token =
            new ZKBridgeToken{salt: salt}(msg.sender, config.name, config.symbol, config.zkBridge, config.chains);

        console.log("address: ", address(token));
        console.log("name: ", token.name());
        console.log("symbol: ", token.symbol());

        vm.stopBroadcast();
    }
}
