// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/EndpointConfig.sol";

/**
 * @notice Deploy the EndpointConfig contract.
 */
contract EndpointConfigDeploy is Script {
    function run(string memory path) external {
        string memory json = vm.readFile(path);
        bytes memory encodedData = vm.parseJson(json);
        console.log("encoded data length: ", encodedData.length);
        EndpointConfig.Global memory config = abi.decode(encodedData, (EndpointConfig.Global));
        console.log("config.chains.length: ", config.chains.length);
        vm.startBroadcast();
        EndpointConfig deployed = new EndpointConfig{salt: 0x0}(config);
        vm.stopBroadcast();
        console.log("address: ", address(deployed));
    }
}
