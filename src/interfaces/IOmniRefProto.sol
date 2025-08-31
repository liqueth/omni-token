// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @title IOmniRefProto
/// @notice Ensures the same contract address exists on every chain, with each instance
/// immutably referencing its chain’s designated local.
/// @dev Deployed deterministically with CREATE2, OmniRef binds immutably to the local
/// local for the current chain. This provides a trustless reference with no governance
/// or upgrade risk, eliminating the need for off-chain registries or per-chain config.
/// Contracts, SDKs, and UIs can hardcode one address and always resolve correctly.
/// Typical uses include cross-chain endpoints (oracles, messengers, executors), wallets,
/// bridges, and explorers that require a single uniform reference across chains.
/// @author Paul Reinholdtsen
interface IOmniRefProto {
    /// @notice Revert if someone tries to reinitialize.
    error AlreadyInitialized();

    /// @notice Revert when the current chain is not supported.
    error UnsupportedChain();

    /// @notice Revert if there is more than one entry with the same chainId.
    error DuplicateChainId();

    /// @notice Revert if any local address is zero.
    error TargetIsZero();

    /// @notice Emit when a clone is created.
    event Cloned(address indexed referrer, address indexed local);

    /// @notice Map a chainId to a local.
    struct Entry {
        uint256 chainId;
        address local;
    }

    /// @notice Predict the address of a created OmniRef.
    /// @dev Revert if clone would revert.
    /// @param entries The array of chainId/local pairs to choose from.
    /// @return global The address of the created or existing clone.
    /// @return salt The salt used to create the clone.
    /// @return local The local address for the current chain.
    function locate(Entry[] memory entries) external view returns (address global, bytes32 salt, address local);

    /// @notice Create a new OmniRef clone for the current chain if it doesn't already exist.
    /// @dev Reverts if the current chain is not supported.
    /// @param entries The array of chainId/local pairs to choose from.
    /// @return global The address of the created or existing clone.
    /// @return salt The salt used to create the clone.
    /// @return local The local address for the current chain.
    function clone(Entry[] memory entries) external returns (address global, bytes32 salt, address local);
}
