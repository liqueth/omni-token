// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMessagingChannel} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessagingChannel.sol";

/// @title MessagingChannelMock
/// @notice A minimal, do-nothing implementation of IMessagingChannel for testing.
contract MessagingChannelMock is IMessagingChannel {
    uint32 public immutable MOCK_EID;

    constructor(uint32 _eid) {
        MOCK_EID = _eid;
    }

    function eid() external view returns (uint32) {}

    // this is an emergency function if a message cannot be verified for some reasons
    // required to provide _nextNonce to avoid race condition
    function skip(address _oapp, uint32 _srcEid, bytes32 _sender, uint64 _nonce) external {}

    function nilify(address _oapp, uint32 _srcEid, bytes32 _sender, uint64 _nonce, bytes32 _payloadHash) external {}

    function burn(address _oapp, uint32 _srcEid, bytes32 _sender, uint64 _nonce, bytes32 _payloadHash) external {}

    function nextGuid(address _sender, uint32 _dstEid, bytes32 _receiver) external view returns (bytes32) {}

    function inboundNonce(address _receiver, uint32 _srcEid, bytes32 _sender) external view returns (uint64) {}

    function outboundNonce(address _sender, uint32 _dstEid, bytes32 _receiver) external view returns (uint64) {}

    function inboundPayloadHash(address _receiver, uint32 _srcEid, bytes32 _sender, uint64 _nonce)
        external
        view
        returns (bytes32)
    {}

    function lazyInboundNonce(address _receiver, uint32 _srcEid, bytes32 _sender) external view returns (uint64) {}
}
