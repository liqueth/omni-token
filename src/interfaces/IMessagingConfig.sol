// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IUintToUint.sol";
import "./IAddressLookup.sol";

/// @notice Read-only interface with the wiring required by
/// [LayerZero V2 Interchain Messaging](https://docs.layerzero.network/v2/developers/evm/overview).
/// @dev Uses deterministic lookup to ensure that the contract can be deployed at the same address across chains,
/// enabling dependent contracts to also deploy to the same address on all chains.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IMessagingConfig {
    /// @notice Struct that mirrors the contents of the contract.
    /// @dev properties are in alphabetical order to simplify converting json to abi-encoded bytes.
    struct Struct {
        IAddressLookup blocker;
        IAddressLookup endpoint;
        IUintToUint endpointMapper;
        IAddressLookup executor;
        IAddressLookup receiver;
        IAddressLookup sender;
    }

    /// @return lookup for this chain's [Blocked Message Library]
    /// (https://docs.layerzero.network/v2/developers/evm/technical-reference/api#blockedmessagelib).
    function blocker() external view returns (IAddressLookup lookup);

    /// @return lookup for this chain's [Endpoint]
    /// (https://docs.layerzero.network/v2/concepts/glossary#endpoint).
    function endpoint() external view returns (IAddressLookup lookup);

    /// @return chainToEid translates a native chainId to its
    /// [Endpoint Identifier (EID)](https://docs.layerzero.network/v2/concepts/glossary#endpoint-id).
    function endpointMapper() external view returns (IUintToUint chainToEid);

    /// @return lookup for this chain's [Executor]
    /// (https://docs.layerzero.network/v2/concepts/glossary#executor).
    function executor() external view returns (IAddressLookup lookup);

    /// @return lookup for this chain's [Message Receive Library]
    /// (https://docs.layerzero.network/v2/concepts/protocol/message-receive-library).
    function receiver() external view returns (IAddressLookup lookup);

    /// @return lookup for this chain's [Message Send Library]
    /// (https://docs.layerzero.network/v2/concepts/protocol/message-send-library).
    function sender() external view returns (IAddressLookup lookup);
}
