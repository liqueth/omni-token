// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/OmniAppConfig.sol";

/**
 * @notice Deploy the OmniAppConfig contract.
 */
contract OmniAppConfigDeploy is Script {
    function run() external {
        string memory path = vm.envString("OmniAppConfigPath");
        string memory json = vm.readFile(path);
        bytes memory encodedData = vm.parseJson(json);
        console.log("encodedData length: ", encodedData.length);
        OmniAppConfig.Global memory config = abi.decode(encodedData, (OmniAppConfig.Global));
        console.log("config.chains.length: ", config.chains.length);
        bytes32 salt = 0x0;
        vm.startBroadcast();
        OmniAppConfig deployed = new OmniAppConfig{salt: salt}(config);
        vm.stopBroadcast();
        console.log("address: ", address(deployed));
    }
}
