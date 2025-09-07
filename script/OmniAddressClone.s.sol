// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OmniAddress.sol";

/**
 * @notice Deploy the OmniAddress factory/implementation contract.
 * @dev Usage: forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
 */
contract OmniAddressClone is Script {
    struct Config {
        string env;
        string id;
        OmniAddress.KeyValue[] keyValues;
    }

    function run() external {
        IOmniAddressCloner cloner = IOmniAddressCloner(vm.envAddress("OmniAddress"));
        string memory path = vm.envString("OmniAddressPath");
        string memory json = vm.readFile(path);
        bytes memory raw = vm.parseJson(json);
        Config memory config = abi.decode(raw, (Config));
        (address clone,) = cloner.cloneAddress(config.keyValues);
        if (clone.code.length == 0) {
            vm.startBroadcast();
            (clone,) = cloner.clone(config.keyValues);
            vm.stopBroadcast();
        }
        console2.log("address:", clone);
    }
}
