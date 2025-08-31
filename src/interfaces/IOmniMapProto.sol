// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Deploy clones of the OmniMap protofactory.
/// @author Paul Reinholdtsen
interface IOmniMapProto {
    /// @notice Map a chainId to a local address.
    struct Entry {
        uint256 chainId;
        address local;
    }

    /// @notice Predict the address of a cloned OmniMap.
    /// @dev Revert on any of the error conditions described below.
    /// @param entries The array of chainId/local pairs to choose from.
    /// @return global The predicted address of the clone.
    /// @return salt The salt used to create the clone.
    /// @return local The local address for the current chain.
    function locate(Entry[] memory entries) external view returns (address global, bytes32 salt, address local);

    /// @notice Create a new OmniMap clone for the current chain if it doesn't already exist.
    /// @dev Revert if locate does.
    /// @param entries The array of chainId/local pairs to choose from.
    /// @return global The predicted address of the clone.
    /// @return salt The salt used to create the clone.
    /// @return local The local address for the current chain.
    function clone(Entry[] memory entries) external returns (address global, bytes32 salt, address local);

    /// @notice Revert if someone tries to reinitialize an instance.
    error AlreadyInitialized();

    /// @notice Revert if the current chain is not supported.
    error UnsupportedChain();

    /// @notice Revert if there is more than one entry with the same chainId.
    error DuplicateChainId();

    /// @notice Revert if any local address is zero.
    error LocalIsZero();

    /// @notice Emit when a clone is created.
    event Cloned(address indexed referrer, address indexed local);
}
