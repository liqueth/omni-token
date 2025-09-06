// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Deploy clones of OmniAddress.
/// @author Paul Reinholdtsen
interface IOmniAddressCloner {
    /// @notice Map a chainId to a local address.
    struct KeyValue {
        uint256 key;
        address value;
    }

    /// @notice Predict the address of a cloned OmniAddress.
    /// @param keyValues The array of key/value pairs mapping chainId to address.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone.
    function cloneAddress(KeyValue[] memory keyValues) external view returns (address clone_, bytes32 salt);

    /// @notice Create a new OmniAddress clone for the current chain if it doesn't already exist.
    /// @param keyValues The array of key/value pairs mapping chainId to address.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(keyValues));
    function clone(KeyValue[] memory keyValues) external returns (address clone_, bytes32 salt);

    /// @notice Revert if someone tries to reinitialize an instance.
    error AlreadyInitialized();

    /// @notice Emit when a clone is created.
    event Cloned(address indexed clone, address indexed value);
}
