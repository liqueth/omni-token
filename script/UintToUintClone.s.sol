// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IUintToUintCloner.sol";

/**
 * @title OmniAddressClone
 * @notice Deploy an OmniAddress clone ONLY if it doesn't already exist (idempotent).
 *
 * @dev Environment variables (required):
 *   - UintToUint       : address of the IOmniAddressCloner contract
 *   - UintToUintPath   : path to JSON config file with { env, id, keyValues }
 *
 * @dev Example:
 *   UintToUintPath=config/testnet/eid.json forge script script/UintToUintClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_API_KEY --broadcast
 */
contract UintToUintClone is Script {
    struct Config {
        string env;
        string id;
        IUintToUint.KeyValue[] keyValues;
    }

    function run() external {
        // Inputs from environment
        IUintToUintCloner cloner = IUintToUintCloner(vm.envAddress("UintToUint"));
        string memory path = vm.envString("UintToUintPath");

        // Read & decode config
        bytes memory raw = vm.parseJson(vm.readFile(path));
        Config memory cfg = abi.decode(raw, (Config));

        // Resolve expected clone address (pure/read-only)
        (address expected,) = cloner.cloneAddress(cfg.keyValues);

        // Basic context logs (human-friendly)
        console2.log("== UintToUintClone ==");
        console2.log("config file:", path);
        console2.log("cloner     :", address(cloner));
        console2.log("expected   :", expected);
        console2.log("chainId    :", block.chainid);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address clone = expected;
        if (clone.code.length == 0) {
            vm.startBroadcast();
            (clone,) = cloner.clone(cfg.keyValues);
            vm.stopBroadcast();
            action = "deployed";
        }

        // Result logs
        console2.log("action     :", action);
        console2.log("address    :", clone);
        console2.log("id         :", cfg.id);
        console2.log("env        :", cfg.env);

        string memory jsonPath = string.concat("./config/", cfg.env, "/UintToUint.json");
        vm.writeJson(vm.toString(clone), jsonPath, string.concat(".", cfg.id));
    }
}
