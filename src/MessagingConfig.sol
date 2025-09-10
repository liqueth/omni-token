// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IMessagingConfig.sol";

/**
 * @title EndpointConfig
 * @notice Chain-local wiring for LayerZero v2 on this network. Provides the immutable addresses
 *         this protocol needs to send/receive messages on *this* chain (endpoint, executor,
 *         send/receive libraries, and blocked-message library), plus a minimal mapping to translate
 *         other chains’ native `chainId` values into their LayerZero Endpoint IDs (EIDs).
 *
 * @dev Cross-chain apps must know, per chain:
 *        • Which EndpointV2 contract to call on this chain.
 *        • Which Executor is used for delivery on this chain.
 *        • Which ULN 302 libraries (send/receive) are configured here.
 *        • This chain’s LayerZero EID (distinct from `chainid`), and how to map peers’ `chainId -> EID`.
 *
 *      Those values differ across networks and are easy to misconfigure if sourced ad hoc. This contract
 *      acts as a *single, immutable source of truth* that other contracts can reference at deploy time
 *      or runtime to: (a) assemble correct messaging parameters, (b) validate routing targets, and
 *      (c) avoid trusting mutable registries or privileged upgraders.
 *
 *      Typical consumers include OFTs and any app that composes directly with EndpointV2/Executor or
 *      needs to compute routing/gas options using the correct local libraries. This contract is not a
 *      router and does not store foreign app addresses; it only exposes the chain-local wiring and a
 *      minimal peer index (native chainId → EID). It is intentionally immutable—no setters, no admins.
 *      Calls should expect reverts for unsupported chains (e.g., zero-EID sentinel).
 *
 * @dev Pattern (deterministic multi-chain config)
 *      • Prepare one canonical dataset off-chain containing a row for each target chain.
 *      • Deploy with CREATE2 using the same init-code and constructor args on every chain so the address
 *        is predictable and identical across networks.
 *      • In the constructor, each instance selects the single row where `chainId == block.chainid` to
 *        initialize its local fields; the remaining rows populate the minimal peer index.
 *      • Inputs must be byte-for-byte identical across chains to preserve the CREATE2 address; adding
 *        new chains later requires a new version (new salt and/or bytecode).
 */
contract MessagingConfig is IMessagingConfig {
    IOmniAddress public immutable blocker;
    IOmniAddress public immutable endpoint;
    IUintToUint public immutable endpointMapper;
    IOmniAddress public immutable executor;
    IOmniAddress public immutable receiver;
    IOmniAddress public immutable sender;

    constructor(IMessagingConfig.Struct memory s) {
        blocker = s.blocker;
        endpoint = s.endpoint;
        endpointMapper = s.endpointMapper;
        executor = s.executor;
        receiver = s.receiver;
        sender = s.sender;
    }
}
