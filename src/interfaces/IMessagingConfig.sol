// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IUintToUint.sol";
import "./IOmniAddress.sol";

/// @notice Read-only interface exposing the chain-local wiring required by LayerZero v2 interchain messaging.
interface IMessagingConfig {
    /// @notice Hold chain specific configuration data.
    struct Struct {
        IOmniAddress blocker;
        IOmniAddress endpoint;
        IUintToUint endpointMapper;
        IOmniAddress executor;
        IOmniAddress receiver;
        IOmniAddress sender;
    }

    /// @return the address of the blocked-message (or “blocker”) library configured on this chain.
    function blocker() external returns (IOmniAddress);

    /// @return the address of the Endpoint contract on this chain.
    function endpoint() external returns (IOmniAddress);

    /// @return the address of contract that translates a native `chainId` to its Endpoint Identifier (EID).
    function endpointMapper() external returns (IUintToUint);

    /// @return the address of the executor used for message delivery on this chain.
    function executor() external returns (IOmniAddress);

    /// @return the receive-library address for this chain.
    function receiver() external returns (IOmniAddress);

    /// @return the address of the chain’s configured “send” library.
    function sender() external returns (IOmniAddress);
}
