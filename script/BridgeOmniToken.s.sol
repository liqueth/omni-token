// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IOmniTokenBridger} from "../src/interfaces/IOmniTokenBridger.sol";

/// @notice Bridge tokens to another chain.
/// @dev Environment variables (required):
///   - token    : path to JSON file with "0x token address"
///   - transfer : path to JSON file with { amount, toChain }
/// @dev Example:
///   token=io/$CHAIN_ID/OMNI_ALPHA.json transfer=io/bridge.json forge script script/BridgeOmniToken.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
contract BridgeOmniToken is Script {
    struct Input {
        uint256 amount;
        uint256 toChain;
    }

    function run() external {
        IOmniTokenBridger token =
            IOmniTokenBridger(abi.decode(vm.parseJson(vm.readFile(vm.envString("token"))), (address)));
        console2.log("token: ", address(token));
        Input memory input = abi.decode(vm.parseJson(vm.readFile(vm.envString("transfer"))), (Input));
        console2.log("toChain: ", input.toChain);
        console2.log("amount: ", input.amount);

        uint256 fee = token.bridgeFee(input.toChain, input.amount);
        console2.log("fee: ", fee);
        vm.startBroadcast();
        token.bridge{value: fee}(input.toChain, input.amount);
        vm.stopBroadcast();
    }
}
