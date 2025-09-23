// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IUintToUint.sol";
import "./IOmniAddress.sol";

/// @notice Read-only interface exposing the chain-local wiring required by LayerZero v2 interchain messaging.
interface IMessagingConfig {
    /// @notice Struct that mirrors the contents of the contract.
    /// @dev properties are in alphabetical order to simplify converting json to abi-encoded bytes.
    struct Struct {
        IOmniAddress blocker;
        IOmniAddress endpoint;
        IUintToUint endpointMapper;
        IOmniAddress executor;
        IOmniAddress receiver;
        IOmniAddress sender;
    }

    /// @return lookup for the blocked-message library configured on this chain.
    function blocker() external view returns (IOmniAddress lookup);

    /// @return lookup for the Endpoint contract on this chain.
    function endpoint() external view returns (IOmniAddress lookup);

    /// @return chainToEid address of contract that translates a native `chainId` to its Endpoint Identifier (EID).
    function endpointMapper() external view returns (IUintToUint chainToEid);

    /// @return lookup for the executor used for message delivery on this chain.
    function executor() external view returns (IOmniAddress lookup);

    /// @return lookup for the receive contract for this chain.
    function receiver() external view returns (IOmniAddress lookup);

    /// @return lookup for the sender contract for this chain.
    function sender() external view returns (IOmniAddress lookup);
}
