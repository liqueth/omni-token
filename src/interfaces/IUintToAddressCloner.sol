// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Deploy clones of a contract that initializes via an array mapping uint to address.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IUintToAddressCloner {
    /// @notice Map a chainId to a local address.
    struct KeyValue {
        uint256 key;
        address value;
    }

    /// @notice Predict the address of a clone.
    /// @param keyValues The array of key value pairs sorted by key.
    /// @return clone The predicted address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(keyValues));
    function cloneAddress(KeyValue[] memory keyValues) external view returns (address clone, bytes32 salt);

    /// @notice Create a clone if it doesn't already exist.
    /// @param keyValues The array of key value pairs sorted by key.
    /// @return clone The address of the new or existing clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(keyValues));
    function clone(KeyValue[] memory keyValues) external returns (address clone, bytes32 salt);

    /// @notice Revert if someone tries to reinitialize an instance.
    error InitializedAlready();

    /// @notice Emit when a clone is created.
    /// @return clone The address of the new clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(keyValues));
    event Cloned(address indexed clone, bytes32 indexed salt);
}
