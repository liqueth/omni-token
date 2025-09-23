// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IUintToUint.sol";
import "./IOmniAddress.sol";

/// @notice Read-only interface with the wiring required by
/// [LayerZero V2 Interchain Messaging](https://docs.layerzero.network/v2/developers/evm/overview).
/// @author Paul Reinholdtsen (reinholdtsen.eth)
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

    /// @return lookup for this chain's [Blocked Message Library]
    /// (https://docs.layerzero.network/v2/developers/evm/technical-reference/api#blockedmessagelib).
    function blocker() external view returns (IOmniAddress lookup);

    /// @return lookup for this chain's [Endpoint]
    /// (https://docs.layerzero.network/v2/concepts/glossary#endpoint).
    function endpoint() external view returns (IOmniAddress lookup);

    /// @return chainToEid translates a native chainId to its
    /// [Endpoint Identifier (EID)](https://docs.layerzero.network/v2/concepts/glossary#endpoint-id).
    function endpointMapper() external view returns (IUintToUint chainToEid);

    /// @return lookup for this chain's [Executor]
    /// (https://docs.layerzero.network/v2/concepts/glossary#executor).
    function executor() external view returns (IOmniAddress lookup);

    /// @return lookup for this chain's [Message Receive Library]
    /// (https://docs.layerzero.network/v2/concepts/protocol/message-receive-library).
    function receiver() external view returns (IOmniAddress lookup);

    /// @return lookup for this chain's [Message Send Library]
    /// (https://docs.layerzero.network/v2/concepts/protocol/message-send-library).
    function sender() external view returns (IOmniAddress lookup);
}
