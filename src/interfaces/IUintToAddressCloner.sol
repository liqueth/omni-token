// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IUintToAddress.sol";

/// @notice Deploy clones of IUintToAddress.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IUintToAddressCloner is IUintToAddress {
    /// @notice Predict the address of a clone.
    /// @param kvs The array of key value pairs sorted by key.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(kvs));
    function cloneAddress(KeyValue[] memory kvs) external view returns (address clone_, bytes32 salt);

    /// @notice Create a clone if it doesn't already exist.
    /// @param kvs The array of key value pairs sorted by key.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(kvs));
    function clone(KeyValue[] memory kvs) external returns (address clone_, bytes32 salt);

    /// @notice Revert if someone tries to reinitialize an instance.
    error AlreadyInitialized();

    /// @notice Emit when a clone is created.
    event Cloned(address indexed clone);
}
