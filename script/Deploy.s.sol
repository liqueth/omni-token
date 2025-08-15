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
        uint256[][] chains;
        uint256[][] mints;
        string name;
        string symbol;
        address zkBridge;
    }

    function run() external {
        string memory path = vm.envString("CONFIG");
        string memory json = vm.readFile(path);
        bytes memory encodedData = vm.parseJson(json);

        Config memory config = abi.decode(encodedData, (Config));
        for (uint256 i = 0; i < config.chains.length; i++) {
            console.log("chain: ", config.chains[i][0]);
            console.log("zkChain: ", config.chains[i][1]);
        }
        for (uint256 i = 0; i < config.mints.length; i++) {
            console.log("chain: ", config.mints[i][0]);
            console.log("amount: ", config.mints[i][1]);
        }

        bytes32 salt = 0x0;

        vm.startBroadcast();

        ZKBridgeToken token = new ZKBridgeToken{salt: salt}(
            msg.sender, config.name, config.symbol, config.zkBridge, config.chains, config.mints
        );

        console.log("address: ", address(token));
        console.log("name: ", token.name());
        console.log("symbol: ", token.symbol());

        vm.stopBroadcast();
    }
}
