// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @title OmniRef
/// @notice Ensures the same contract address exists on every chain, with each instance
/// immutably referencing its chain’s designated target.
/// @dev Deployed deterministically with CREATE2, OmniRef binds immutably to the local
/// target for the current chain. This provides a trustless reference with no governance
/// or upgrade risk, eliminating the need for off-chain registries or per-chain config.
/// Contracts, SDKs, and UIs can hardcode one address and always resolve correctly.
/// Typical uses include cross-chain endpoints (oracles, messengers, executors), wallets,
/// bridges, and explorers that require a single uniform reference across chains.
/// @author Paul Reinholdtsen
interface IOmniRef {
    /// @notice Revert if someone tries to reinitialize.
    error AlreadyInitialized();

    /// @notice Revert when the current chain is not supported.
    error UnsupportedChain();

    /// @notice Revert if there is more than one entry with the same chainId.
    error DuplicateChainId();

    /// @notice Revert if any target address is zero.
    error TargetIsZero();

    /// @notice Emit when a clone is created.
    event Created(address indexed referrer, address indexed target);

    /// @notice Map a chainId to a target.
    struct Entry {
        uint256 chainId;
        address target;
    }

    /// @notice Predict the address of a created OmniRef.
    /// @dev Does not validate the entries or whether the clone exists.
    /// @param entries The array of chainId/target pairs to choose from.
    /// @return ref The address of the created or existing clone.
    /// @return salt The salt used to create the clone.
    function createPrediction(Entry[] memory entries) external view returns (address ref, bytes32 salt);

    /// @notice Create a new OmniRef clone for the current chain if it doesn't already exist.
    /// @dev Reverts if the current chain is not supported.
    /// @param entries The array of chainId/target pairs to choose from.
    /// @return ref The address of the created or existing clone.
    /// @return salt The salt used to create the clone.
    function create(Entry[] memory entries) external returns (address ref, bytes32 salt);

    /// @notice Return the chain‑specific address for this chain.
    function target() external view returns (address);
}
