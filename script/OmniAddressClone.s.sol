// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OmniAddress.sol";

/**
 * @title OmniAddressClone
 * @notice Deploy an OmniAddress clone ONLY if it doesn't already exist (idempotent).
 *
 * @dev Environment variables (required):
 *   - OmniAddress       : address of the IOmniAddressCloner contract
 *   - OmniAddressPath   : path to JSON config file with { env, id, keyValues }
 *   - DEPLOYER_ADDRESS  : (for logging only) the EVM address of the broadcaster
 *
 * @dev Example:
 *   forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
 *   OmniAddressPath=config/testnet/dvn/google-cloud.json forge script script/OmniAddressClone.s.sol --rpc-url $CHAIN_ID --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_KEY --broadcast
 *
 * @dev Output:
 *   - Human-readable logs with the resolved/created clone address and context.
 *   - Final single-line JSON for easy piping:
 *       {"action":"reused|deployed","address":"0x...","env":"...","id":"...","chainId":"...","deployer":"0x..."}
 */
contract OmniAddressClone is Script {
    struct Config {
        string env;
        string id;
        OmniAddress.KeyValue[] keyValues;
    }

    function run() external {
        // Inputs from environment
        IOmniAddressCloner cloner = IOmniAddressCloner(vm.envAddress("OmniAddress"));
        string memory path = vm.envString("OmniAddressPath");
        address deployer = vm.envAddress("DEPLOYER_ADDRESS");

        // Read & decode config
        bytes memory raw = vm.parseJson(vm.readFile(path));
        Config memory cfg = abi.decode(raw, (Config));

        // Resolve expected clone address (pure/read-only)
        (address expected,) = cloner.cloneAddress(cfg.keyValues);

        // Basic context logs (human-friendly)
        console2.log("== OmniAddressClone ==");
        console2.log("config file:", path);
        console2.log("cloner     :", address(cloner));
        console2.log("expected   :", expected);
        console2.log("chainId    :", block.chainid);
        console2.log("deployer   :", deployer);

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

        // Machine-friendly final line (compact JSON)
        console2.log(
            string.concat(
                '{"action":"', action,
                '","address":"', vm.toString(clone),
                '","env":"', cfg.env,
                '","id":"', cfg.id,
                '","chainId":"', vm.toString(block.chainid),
                '","deployer":"', vm.toString(deployer),
                '"}'
            )
        );
    }
}
