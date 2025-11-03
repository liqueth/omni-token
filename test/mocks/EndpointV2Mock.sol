// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {
    ILayerZeroEndpointV2,
    MessagingFee,
    MessagingParams,
    MessagingReceipt,
    Origin
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {MessagingChannelMock} from "./MessagingChannelMock.sol";
import {MessageLibManagerMock} from "./MessageLibManagerMock.sol";
import {MessagingComposerMock} from "./MessagingComposerMock.sol";
import {MessagingContextMock} from "./MessagingContextMock.sol";

/// @title EndpointV2Mock
/// @notice A no-op mock implementation of ILayerZeroEndpointV2 for testing.
/// @dev Fully implements the interface but performs no logic.
contract EndpointV2Mock is
    ILayerZeroEndpointV2,
    MessagingChannelMock,
    MessageLibManagerMock,
    MessagingComposerMock,
    MessagingContextMock
{
    constructor(uint32 _eid, address _owner) MessagingChannelMock(_eid) {
        //_transferOwnership(_owner);
    }

    function quote(MessagingParams calldata _params, address _sender) external view returns (MessagingFee memory) {}

    function send(MessagingParams calldata _params, address _refundAddress)
        external
        payable
        returns (MessagingReceipt memory)
    {}

    function verify(Origin calldata _origin, address _receiver, bytes32 _payloadHash) external {}

    function verifiable(Origin calldata _origin, address _receiver) external view returns (bool) {}

    function initializable(Origin calldata _origin, address _receiver) external view returns (bool) {}

    function lzReceive(
        Origin calldata _origin,
        address _receiver,
        bytes32 _guid,
        bytes calldata _message,
        bytes calldata _extraData
    ) external payable {}

    // oapp can burn messages partially by calling this function with its own business logic if messages are verified in order
    function clear(address _oapp, Origin calldata _origin, bytes32 _guid, bytes calldata _message) external {}

    function setLzToken(address _lzToken) external {}

    function lzToken() external view returns (address) {}

    function nativeToken() external view returns (address) {}

    function setDelegate(address _delegate) external {}
}
