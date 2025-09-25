// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IOmniTokenBridger} from "../src/interfaces/IOmniTokenBridger.sol";
import {MessagingReceipt, OFTReceipt} from "@layerzerolabs/oft-evm/contracts/oft/interfaces/IOFT.sol";

/// @notice Bridge tokens to another chain.
/// @dev Environment variables (required):
///   - token    : path to JSON file with "0x token address"
///   - transfer : path to JSON file with { amount, toChain }
/// @dev Example:
///   token=io/$chain/OMNI_ALPHA.json transfer=io/bridge.json forge script script/BridgeOmniToken.s.sol -f $chain --private-key $tx_key --broadcast
contract BridgeOmniToken is Script {
    struct Input {
        uint256 amount;
        uint256 toChain;
    }

    function run() external {
        console2.log("script : BridgeOmniToken");
        address token = abi.decode(vm.parseJson(vm.readFile(vm.envString("token"))), (address));
        console2.log("token  :", address(token));
        Input memory input = abi.decode(vm.parseJson(vm.readFile(vm.envString("transfer"))), (Input));
        console2.log("amount :", input.amount);
        console2.log("toChain:", input.toChain);

        uint256 fee = IOmniTokenBridger(token).bridgeFee(input.toChain, input.amount);
        console2.log("fee    :", fee);
        vm.startBroadcast();
        (MessagingReceipt memory msgRct, OFTReceipt memory oftRct) =
            IOmniTokenBridger(token).bridge{value: fee}(input.toChain, input.amount);
        vm.stopBroadcast();

        console2.log("msgRct.fee.nativeFee   :", msgRct.fee.nativeFee);
        console2.log("msgRct.fee.lzTokenFee  :", msgRct.fee.lzTokenFee);
        console2.log("msgRct.guid            :");
        console2.logBytes32(msgRct.guid);
        console2.log("msgRct.nonce           :", msgRct.nonce);
        console2.log("oftRct.amountSentLD    :", oftRct.amountSentLD);
        console2.log("oftRct.amountReceivedLD:", oftRct.amountReceivedLD);
    }
}
