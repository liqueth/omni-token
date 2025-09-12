// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IOmniTokenCloner.sol";

/**
 * @title OmniAddressClone
 * @notice Deploy an OmniAddress clone ONLY if it doesn't already exist (idempotent).
 *
 * @dev Environment variables (required):
 *   - OmniAddress       : address of the IOmniAddressCloner contract
 *   - OmniAddressPath   : path to JSON config file with { env, id, keyValues }
 *
 * @dev Example:
 *   OmniTokenPath=config/OMNI_ALPHA.json forge script script/OmniTokenClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
 */
contract OmniTokenClone is Script {
    function run() external {
        // Inputs from environment
        IOmniTokenCloner cloner = IOmniTokenCloner(vm.envAddress("OmniToken"));
        string memory path = vm.envString("OmniTokenPath");

        // Read & decode config
        bytes memory raw = vm.parseJson(vm.readFile(path));
        IOmniTokenCloner.Config memory cfg = abi.decode(raw, (IOmniTokenCloner.Config));

        // Resolve expected clone address (pure/read-only)
        (address expected,) = cloner.cloneAddress(cfg);

        // Basic context logs (human-friendly)
        console2.log("== OmniTokenClone ==");
        console2.log("config file:", path);
        console2.log("cloner     :", address(cloner));
        console2.log("expected   :", expected);
        console2.log("chainId    :", block.chainid);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address clone = expected;
        if (clone.code.length == 0) {
            vm.startBroadcast();
            (clone,) = cloner.clone(cfg);
            vm.stopBroadcast();
            action = "deployed";
        }

        // Result logs
        console2.log("action     :", action);
        console2.log("address    :", clone);
        console2.log("symbol     :", cfg.symbol);

        string memory env = vm.envString("CHAIN_ENV");
        string memory jsonPath = string.concat("./config/", env, "/OmniToken.json");
        vm.writeJson(vm.toString(clone), jsonPath, string.concat(".", cfg.symbol));
    }
}
