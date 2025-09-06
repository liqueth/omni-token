// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Deploy clones of UintToUint.
/// @author Paul Reinholdtsen
interface IUintToUintCloner {
    /// @notice Map a key to a value.
    struct KeyValue {
        uint256 key;
        uint256 value;
    }

    /// @notice Predict the address of a clone.
    /// @param keyValues The array of key value pairs sorted by key.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone.
    function cloneAddress(KeyValue[] memory keyValues) external view returns (address clone_, bytes32 salt);

    /// @notice Create a clone if it doesn't already exist.
    /// @param keyValues The array of key value pairs sorted by key.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(keyValues));
    function clone(KeyValue[] memory keyValues) external returns (address clone_, bytes32 salt);

    /// @notice Revert if someone tries to reinitialize an instance.
    error AlreadyInitialized();

    /// @notice Emit when a clone is created.
    event Cloned(address indexed clone);
}
