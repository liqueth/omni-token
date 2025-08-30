// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/OmniRef.sol";

/**
 * @notice Deploy the OmniRef factory/implementation contract.
 */
contract OmniRefFactory is Script {
    function run() external {
        vm.startBroadcast();
        OmniRef deployed = new OmniRef{salt: 0x0}();
        vm.stopBroadcast();
        console.log("address: ", address(deployed));
    }
}
