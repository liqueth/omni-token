// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @title OmniRef
/// @notice Ensures the same contract address exists on every chain, with each instance
/// immutably referencing its chain’s designated local.
/// @dev Deployed deterministically with CREATE2, OmniRef binds immutably to the local
/// local for the current chain. This provides a trustless reference with no governance
/// or upgrade risk, eliminating the need for off-chain registries or per-chain config.
/// Contracts, SDKs, and UIs can hardcode one address and always resolve correctly.
/// Typical uses include cross-chain endpoints (oracles, messengers, executors), wallets,
/// bridges, and explorers that require a single uniform reference across chains.
/// @author Paul Reinholdtsen
interface IOmniRef {
    /// @notice Return the chain‑specific address for this chain.
    function local() external view returns (address);
}
