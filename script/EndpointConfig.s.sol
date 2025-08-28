// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/EndpointConfig.sol";

/**
 * @notice Deploy the EndpointConfig contract.
 */
contract EndpointConfigDeploy is Script {
    function run() external {
        string memory path = vm.envString("EndpointConfigPath");
        string memory json = vm.readFile(path);
        bytes memory encodedData = vm.parseJson(json);
        console.log("encodedData length: ", encodedData.length);
        EndpointConfig.Global memory config = abi.decode(encodedData, (EndpointConfig.Global));
        console.log("config.chains.length: ", config.chains.length);
        bytes32 salt = 0x0;
        vm.startBroadcast();
        EndpointConfig deployed = new EndpointConfig{salt: salt}(config);
        vm.stopBroadcast();
        console.log("address: ", address(deployed));
    }
}
