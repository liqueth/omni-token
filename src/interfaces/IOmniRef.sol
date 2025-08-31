// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice OmniRef maps a uniform contract address across chains to a chain specific address.
/// @dev Deployed at the same address on every chain, OmniRef immutably binds to
/// the chain’s local target, providing a trustless reference with no governance
/// or upgrade risk. This removes off-chain registries and per-chain config,
/// letting contracts, SDKs, and UIs hardcode one address and always resolve locally.
/// Applications: cross-chain endpoints (oracles/messengers/executors), wallets/bridges
/// and explorers needing a single, immutable address that maps to the correct local contract.
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

    /// @notice Emit when the target address is referenced during initialization.
    event Referenced(address indexed target);

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
