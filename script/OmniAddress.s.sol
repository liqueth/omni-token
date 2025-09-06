// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/OmniAddress.sol";

/**
 * @notice Deploy the OmniAddress factory/implementation contract.
 * @dev Usage: forge script script/OmniAddressProto.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify --delay 10 --retries 10
 */
contract OmniAddressFactory is Script {
    function run() external {
        vm.startBroadcast();
        OmniAddress deployed = new OmniAddress{salt: 0x0}();
        vm.stopBroadcast();
        console.log("address: ", address(deployed));
    }
}
