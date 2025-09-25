// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/interfaces/IUintToAddressProto.sol";

/// @title AddressLookupClone
/// @notice Deploy an AddressLookup clone ONLY if it doesn't already exist (idempotent).
/// @dev Environment variables (required):
///   - AddressLookup       : address of the IAddressLookupCloner contract
///   - UintToAddressPath   : path to JSON config file with { env, id, keyValues }
/// @dev Example:
///   UintToAddressPath=config/testnet/dvn/google-cloud.json forge script script/UintToAddressClone.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
contract UintToAddressClone is Script {
    struct Config {
        string env;
        string id;
        IUintToAddress.KeyValue[] keyValues;
    }

    function run() external {
        // Inputs from environment
        IUintToAddressProto cloner = IUintToAddressProto(vm.envAddress("UintToAddressProto"));
        string memory path = vm.envString("UintToAddressPath");

        // Read & decode config
        bytes memory raw = vm.parseJson(vm.readFile(path));
        Config memory cfg = abi.decode(raw, (Config));

        // Resolve predicted clone address (pure/read-only)
        (address predicted,) = cloner.cloneAddress(cfg.keyValues);

        // Basic context logs (human-friendly)
        console2.log("== UintToAddressClone ==");
        console2.log("config file:", path);
        console2.log("cloner     :", address(cloner));
        console2.log("predicted   :", predicted);
        console2.log("chainId    :", block.chainid);

        // Idempotent deploy (only broadcast if bytecode missing)
        string memory action = "reused";
        address clone = predicted;
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

        string memory jsonPath = string.concat("./config/", cfg.env, "/UintToAddressProto.json");
        vm.writeJson(vm.toString(clone), jsonPath, string.concat(".", cfg.id));
    }
}
