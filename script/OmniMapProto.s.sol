// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/OmniMap.sol";

/**
 * @notice Deploy the OmniMap factory/implementation contract.
 * @dev Usage: forge script script/OmniMapProto.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify --delay 10 --retries 10
 */
contract OmniMapFactory is Script {
    function run() external {
        vm.startBroadcast();
        OmniMap deployed = new OmniMap{salt: 0x0}();
        vm.stopBroadcast();
        console.log("address: ", address(deployed));
    }
}
