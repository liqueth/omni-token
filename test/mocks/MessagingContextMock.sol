// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMessagingContext} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessagingContext.sol";

/// @title MessagingChannelMock
/// @notice A minimal, do-nothing implementation of IMessagingChannel for testing.
contract MessagingContextMock is IMessagingContext {
    function isSendingMessage() external view returns (bool) {}

    function getSendContext() external view returns (uint32 dstEid, address sender) {}
}
