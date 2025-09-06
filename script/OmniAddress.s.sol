// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OmniAddress.sol";

/**
 * @notice Deploy the OmniAddress factory/implementation contract.
 * @dev Usage: forge script script/OmniAddress.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast --verify --delay 10 --retries 10
 */
contract OmniAddressScript is Script {
    function run() external {
        address predicted = vm.computeCreate2Address(0x0, keccak256(type(OmniAddress).creationCode));
        bool exists = predicted.code.length != 0;
        if (!exists) {
            vm.startBroadcast();
            new OmniAddress{salt: 0x0}();
            vm.stopBroadcast();
        }

        // machine-parsable
        console.log("address:", predicted);
        console.log("status:", exists ? "exists" : "deployed");
    }
}
