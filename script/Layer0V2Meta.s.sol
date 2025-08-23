// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {Layer0V2Meta} from "../src/Layer0V2Meta.sol";

contract Layer0V2MetaDeploy is Script {
    function run() external {
        // Path to the JSON produced above (set via env for flexibility)
        string memory path = vm.envString("Layer0V2MetaConfigPath");
        string memory json = vm.readFile(path);

        // Decode into the exact struct array your contract expects (no isTestnet)
        bytes memory raw = vm.parseJson(json, ".rows");
        Layer0V2Meta.Row[] memory rows = abi.decode(raw, (Layer0V2Meta.Row[]));

        vm.startBroadcast();
        Layer0V2Meta reg = new Layer0V2Meta(rows);
        vm.stopBroadcast();

        console2.log("Layer0V2Meta deployed at", address(reg));
        console2.log("Rows loaded:", rows.length);
    }
}
