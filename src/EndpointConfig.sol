// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OmniConfig.sol";
import "./interfaces/IEndpointConfig.sol";

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
contract EndpointConfig is OmniConfig, IEndpointConfig {
    /// @notice Hold chain specific configuration data.
    struct Chain {
        address blocker;
        uint256 chainId;
        uint32 eid;
        address endpoint;
        address executor;
        address receiver;
        address sender;
    }

    /// @notice Hold configuration data common to all chains.
    struct Global {
        Chain[] chains;
        uint256 version;
    }

    mapping(uint256 => uint32) public _chainToEndpoint;
    address public immutable blocker;
    address public immutable endpoint;
    address public immutable executor;
    address public immutable receiver;
    address public immutable sender;

    constructor(Global memory global) {
        version = global.version;
        uint256 n = global.chains.length;
        _chains = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            Chain memory r = global.chains[i];
            _chains[i] = r.chainId;
            _chainToEndpoint[r.chainId] = r.eid;
            if (r.chainId == block.chainid) {
                blocker = r.blocker;
                endpoint = r.endpoint;
                executor = r.executor;
                receiver = r.receiver;
                sender = r.sender;
            }
        }

        if (endpoint == address(0)) {
            revert UnsupportedChain();
        }
    }

    /// @notice Lookup the remote EID for a native `chain`.
    /// @dev Revert with `UnsupportedDestinationChain` if the mapping is empty (0 sentinel).
    function chainToEndpoint(uint256 chain) external view returns (uint32 eid) {
        eid = _chainToEndpoint[chain];
        if (eid == 0) {
            revert UnsupportedDestinationChain(chain);
        }
    }
}
