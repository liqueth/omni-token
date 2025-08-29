// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/VerifierConfig.sol";

contract VerifierConfigDeploy is Script {
    function run() external {
        string memory env = vm.envString("CHAIN_ENV");
        string memory dvnid = vm.envString("DVN_ID");
        string memory path = string.concat("config/dvn/", dvnid, "-", env, ".json");
        string memory json = vm.readFile(path);
        bytes memory encodedData = vm.parseJson(json);
        console.log("encodedData length: ", encodedData.length);
        VerifierConfig.Global memory config = abi.decode(encodedData, (VerifierConfig.Global));
        console.log("config.chains.length: ", config.chains.length);
        bytes32 salt = 0x0;
        vm.startBroadcast();
        VerifierConfig deployed = new VerifierConfig{salt: salt}(config);
        vm.stopBroadcast();
        console.log("address: ", address(deployed));
    }
}
