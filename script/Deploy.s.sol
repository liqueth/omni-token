// SPDX-License-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "../src/ZKBridgeToken.sol";

contract Deploy is Script {
    using stdJson for string;

    struct Config {
        ZKBridgeToken.ChainConfig[] chainConfigs;
        string name;
        string symbol;
        address zkBridge;
    }

    function run() external {
        string memory path = vm.envString("CONFIG");
        string memory json = vm.readFile(path);
        bytes memory encodedData = vm.parseJson(json);

        Config memory config = abi.decode(encodedData, (Config));

        bytes32 salt = 0x0;

        vm.startBroadcast();

        ZKBridgeToken token = new ZKBridgeToken{salt: salt}(
            config.name,
            config.symbol,
            config.zkBridge,
            config.chainConfigs
        );

        token;

        vm.stopBroadcast();
    }
}
