// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {Layer0V2Meta} from "../src/Layer0V2Meta.sol";

contract Layer0V2MetaDeploy is Script {
    struct Config {
        Layer0V2Meta.Row[] rows;
    }

    function run() external {
        // Path to the JSON produced above (set via env for flexibility)
        string memory path = vm.envString("Layer0V2MetaConfigPath");
        string memory json = vm.readFile(path);
        console.log("JSON loaded");

        bytes memory encodedData = vm.parseJson(json);
        console.log("JSON parsed");
        Config memory config = abi.decode(encodedData, (Config));
        console.log("Rows loaded:", config.rows.length);

        bytes32 salt = 0x0;

        vm.startBroadcast();
        Layer0V2Meta reg = new Layer0V2Meta{salt: salt}(config.rows);
        vm.stopBroadcast();

        console.log("Layer0V2Meta deployed at", address(reg));
        console.log("Rows loaded:", config.rows.length);
    }
}
