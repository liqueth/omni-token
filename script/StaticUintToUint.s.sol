// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/StaticUintToUint.sol";

/**
 * @notice Deploy the OmniAddress factory/implementation contract.
 * @dev Usage: forge script script/StaticUintToUint.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify --delay 10 --retries 10
 */
contract StaticUintToUintDeploy is Script {
    function run() external {
        vm.startBroadcast();
        StaticUintToUint deployed = new StaticUintToUint{salt: 0x0}();
        vm.stopBroadcast();
        console.log("address: ", address(deployed));
    }
}
