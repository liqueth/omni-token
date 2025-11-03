// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMessagingComposer} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessagingComposer.sol";

/// @title MessagingChannelMock
/// @notice A minimal, do-nothing implementation of IMessagingChannel for testing.
contract MessagingComposerMock is IMessagingComposer {
    function composeQueue(address _from, address _to, bytes32 _guid, uint16 _index)
        external
        view
        returns (bytes32 messageHash)
    {}

    function sendCompose(address _to, bytes32 _guid, uint16 _index, bytes calldata _message) external {}

    function lzCompose(
        address _from,
        address _to,
        bytes32 _guid,
        uint16 _index,
        bytes calldata _message,
        bytes calldata _extraData
    ) external payable {}
}
