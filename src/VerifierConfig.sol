// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OmniConfig.sol";

/**
 * @title VerifierConfig
 * @notice Immutable per-chain verifier configuration, deployed deterministically at a predictable address.
 * @dev Purpose:
 *      Cross-chain protocols often rely on independent verifiers (e.g., DVNs) to attest to message correctness.
 *      Each chain needs to know which verifier address to trust locally, and consumers need a stable identifier
 *      that names the verifier across all chains.
 *
 *      This contract provides:
 *        • The verifier address (`dvn`) specific to the current `block.chainid`.
 *        • A canonical string identifier (`id`) naming the verifier set/operator across chains.
 *        • A version number (inherited from OmniConfig) so dependents can pin to a specific dataset.
 *        • A list of supported native chain IDs (inherited `_chains`) for discoverability.
 *
 *      Construction takes a global dataset covering all target chains, selects the row matching
 *      the current chain’s `chainid` to set the local verifier, and records global metadata.
 *      If the current chain is not listed, deployment reverts with `UnsupportedChain()`.
 *
 *      Pattern (deterministic omnichain configuration):
 *        • One canonical dataset is prepared off-chain and passed identically to every deployment.
 *        • Deployment uses CREATE2 (same init-code + args) so the address is identical across networks.
 *        • Each instance selects its own row via `block.chainid`; no setters or privileged updates.
 */

/// @notice Customize per chain.
contract VerifierConfig is OmniConfig {
    /**
     * @notice Per-chain verifier row.
     * @dev Represents the mapping between a native `chainId` and the verifier address
     *      trusted on that chain (e.g., a DVN contract). Exactly one row should match
     *      the current `block.chainid` during construction.
     */
    struct Chain {
        /// @notice Native EVM chain identifier (e.g., 1 for Ethereum mainnet).
        uint256 chainId;
        /// @notice Verifier address used on this chain (e.g., DVN contract).
        address dvn;
    }

    /**
     * @notice Global dataset supplied at construction time.
     * @dev Contains:
     *      - `chains`: the list of per-chain rows, including the current chain.
     *      - `id`: a canonical, human-readable identifier for the verifier set/operator
     *              (e.g., "axelar", "bitgo", "animoca-blockdaemon").
     *      - `version`: monotonically increasing dataset/version number for pinning.
     *      Implementations are expected to pass the *same* `Global` payload on every chain
     *      to preserve CREATE2 address determinism.
     */
    struct Global {
        Chain[] chains;
        string id;
        uint256 version;
    }

    /// @notice Canonical identifier string naming the verifier across chains.
    string internal _id;

    /// @notice Verifier address used on this chain (set once in the constructor).
    address public immutable dvn;

    /**
     * @notice Initialize immutable verifier config from a canonical global dataset.
     * @dev Side effects:
     *      - Copies `global.version` into inherited `version`.
     *      - Copies `global.id` into `_id`.
     *      - Populates inherited `_chains` with all provided `chainId`s for discovery.
     *      - Sets `dvn` to the verifier address for `block.chainid`.
     *      Reverts with `UnsupportedChain()` (from OmniConfig) if no matching row is found.
     */
    constructor(Global memory global) {
        version = global.version;
        _id = global.id;
        uint256 n = global.chains.length;
        _chains = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            Chain memory r = global.chains[i];
            _chains[i] = r.chainId;
            if (r.chainId == block.chainid) {
                dvn = r.dvn;
            }
        }

        if (dvn == address(0)) {
            revert UnsupportedChain();
        }
    }

    /**
     * @notice Canonical identifier string for this verifier configuration.
     * @dev Human-readable and stable across chains; does not imply address equality.
     */
    function id() external view returns (string memory) {
        return _id;
    }
}
