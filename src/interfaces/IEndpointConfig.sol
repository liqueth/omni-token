// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IOmniConfig.sol";

/**
 * @title IEndpointConfig
 * @notice Read-only interface exposing the chain-local wiring and minimal peer mapping
 *         required by omnichain messaging protocols (e.g., LayerZero v2).
 * @dev Purpose:
 *      - Provide immutable addresses used on *this* chain for message send/receive and delivery.
 *      - Provide a way to translate a native `chainId` to that chain’s Endpoint Identifier (EID).
 *      - Report destination-chain unsupport via a standard error.
 *
 * Inherits:
 *      - {IOmniConfig}: common surface for versioning and enumerating supported native chain IDs.
 */
interface IEndpointConfig is IOmniConfig {
    /**
     * @notice Thrown when a destination chain is not supported by this configuration.
     * @param chain Native `chainId` of the unsupported destination chain.
     */
    error UnsupportedDestinationChain(uint256 chain);

    /**
     * @notice Address of the blocked-message (or “blocker”) library configured on this chain.
     * @dev Used to handle/guard blocked message flows at the protocol layer.
     * Implementations SHOULD make this a pure accessor (no state changes).
     * @return The blocker library address for this chain.
     */
    function blocker() external returns (address);

    /**
     * @notice Address of the Endpoint contract on this chain.
     * @dev Contracts call this Endpoint to send/receive messages for the protocol.
     * Implementations SHOULD make this a pure accessor (no state changes).
     * @return The Endpoint address for this chain.
     */
    function endpoint() external returns (address);

    /**
     * @notice Address of the Executor used for message delivery on this chain.
     * @dev Used by the messaging protocol to execute deliveries/callbacks.
     * Implementations SHOULD make this a pure accessor (no state changes).
     * @return The Executor address for this chain.
     */
    function executor() external returns (address);

    /**
     * @notice Address of the chain’s configured receive library.
     * @dev Library used when receiving inbound messages to this chain.
     * Implementations SHOULD make this a pure accessor (no state changes).
     * @return The receive-library address for this chain.
     */
    function receiver() external returns (address);

    /**
     * @notice Address of the chain’s configured “send” library.
     * @dev Library used when composing outbound messages from this chain.
     * Implementations SHOULD make this a pure accessor (no state changes).
     * @return The send-library address for this chain.
     */
    function sender() external returns (address);

    /**
     * @notice Translate a native `chainId` to its Endpoint Identifier (EID).
     * @dev Reverts with {UnsupportedDestinationChain} if the destination is not supported.
     *      EIDs are protocol-specific numeric identifiers (distinct from EVM `chainId`).
     * @param chain Native `chainId` of the destination chain to query.
     * @return eid The protocol Endpoint Identifier corresponding to `chain`.
     */
    function eidOf(uint256 chain) external returns (uint32 eid);
}
