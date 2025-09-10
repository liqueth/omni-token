// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@forge-std/src/Script.sol";
import "../src/interfaces/IUintToAddressCloner.sol";

/**
 * @title OmniAddressClone
 * @notice Deploy an OmniAddress clone ONLY if it doesn't already exist (idempotent).
 *
 * @dev Environment variables (required):
 *   - OmniAddress       : address of the IOmniAddressCloner contract
 *   - UintToAddressPath   : path to JSON config file with { env, id, keyValues }
 *
 * @dev Example:
 *   UintToAddressPath=config/testnet/dvn/google-cloud.json forge script script/UintToAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
 */
contract UintToAddressClone is Script {
    struct Config {
        string env;
        string id;
        IUintToAddress.KeyValue[] keyValues;
    }

    function run() external {
        // Inputs from environment
        IUintToAddressCloner cloner = IUintToAddressCloner(vm.envAddress("UintToAddress"));
        string memory path = vm.envString("UintToAddressPath");

        // Read & decode config
        bytes memory raw = vm.parseJson(vm.readFile(path));
        Config memory cfg = abi.decode(raw, (Config));

        // Resolve expected clone address (pure/read-only)
        (address expected,) = cloner.cloneAddress(cfg.keyValues);

        // Basic context logs (human-friendly)
        console2.log("== UintToAddressClone ==");
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

        string memory jsonPath = string.concat("./config/", cfg.env, "/UintToAddress.json");
        vm.writeJson(vm.toString(clone), jsonPath, string.concat(".", cfg.id));
    }
}
