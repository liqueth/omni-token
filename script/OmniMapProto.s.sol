// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/OmniMap.sol";

/**
 * @notice Deploy the OmniMap factory/implementation contract.
 */
contract OmniMapFactory is Script {
    function run() external {
        vm.startBroadcast();
        OmniMap deployed = new OmniMap{salt: 0x0}();
        vm.stopBroadcast();
        console.log("address: ", address(deployed));
    }
}
