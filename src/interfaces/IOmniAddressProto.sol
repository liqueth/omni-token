// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Deploy clones of the OmniAddress protofactory.
/// @author Paul Reinholdtsen
interface IOmniAddressProto {
    /// @notice Map a chainId to a local address.
    struct Entry {
        uint256 chainId;
        address local;
    }

    /// @notice Predict the address of a cloned OmniAddress.
    /// @dev Revert on any of the error conditions described below.
    /// @param entries The array of chainId/local pairs to choose from.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone.
    function cloneAddress(Entry[] memory entries) external view returns (address clone_, bytes32 salt);

    /// @notice Create a new OmniAddress clone for the current chain if it doesn't already exist.
    /// @dev Revert if locate does.
    /// @param entries The array of chainId/local pairs to choose from.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(entries));
    function clone(Entry[] memory entries) external returns (address clone_, bytes32 salt);

    /// @notice Revert if someone tries to reinitialize an instance.
    error AlreadyInitialized();

    /// @notice Emit when a clone is created.
    event Cloned(address indexed referrer, address indexed local);
}
