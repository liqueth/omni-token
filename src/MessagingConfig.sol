// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IMessagingConfig.sol";

/// @notice Implementation of IMessagingConfig
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract MessagingConfig is IMessagingConfig {
    IAddressLookup public immutable blocker;
    IAddressLookup public immutable endpoint;
    IUintToUint public immutable endpointMapper;
    IAddressLookup public immutable executor;
    IAddressLookup public immutable receiver;
    IAddressLookup public immutable sender;

    constructor(IMessagingConfig.Struct memory s) {
        blocker = s.blocker;
        endpoint = s.endpoint;
        endpointMapper = s.endpointMapper;
        executor = s.executor;
        receiver = s.receiver;
        sender = s.sender;
    }
}
