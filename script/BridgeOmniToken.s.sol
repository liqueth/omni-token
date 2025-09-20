// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IOmniToken} from "../src/interfaces/IOmniToken.sol";

/**
 * @title BridgeOmniToken
 * @notice Bridge tokens to another chain.
 *
 * @dev Environment variables (required):
 *   - TOKEN : address of the IOmniToken contract
 *   - IN    : path to JSON config file with { env, id, keyValues }
 *
 * @dev Example:
 *   TOKEN=io/$CHAIN_ID/OMNI_ALPHA.json IN=io/bridge.json forge script script/BridgeOmniToken.s.sol -f $CHAIN_ID --private-key $DEPLOYER_KEY --broadcast
 */
contract BridgeOmniToken is Script {
    struct Input {
        uint256 amount;
        uint256 toChain;
    }

    function run() external {
        IOmniToken token = IOmniToken(abi.decode(vm.parseJson(vm.readFile(vm.envString("TOKEN"))), (address)));
        console2.log("token: ", address(token));
        Input memory input = abi.decode(vm.parseJson(vm.readFile(vm.envString("IN"))), (Input));
        console2.log("toChain: ", input.toChain);
        console2.log("amount: ", input.amount);

        uint256 fee = token.bridgeQuote(input.toChain, input.amount);
        console2.log("fee: ", fee);
        vm.startBroadcast();
        token.bridge{value: fee}(input.toChain, input.amount);
        vm.stopBroadcast();
    }
}
