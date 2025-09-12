// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IOmniToken.sol";

/// @notice Deploy clones of IUintToAddress.
/// @author Paul Reinholdtsen
interface IOmniTokenCloner is IOmniToken {
    struct Config {
        uint256[][] mints;
        string name;
        address owner;
        string symbol;
    }

    /// @notice Predict the address of a clone.
    /// @param config The configuration for the clone.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(kvs));
    function cloneAddress(Config memory config) external view returns (address clone_, bytes32 salt);

    /// @notice Create a clone if it doesn't already exist.
    /// @param config The configuration for the clone.
    /// @return clone_ The predicted address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(kvs));
    function clone(Config memory config) external returns (address clone_, bytes32 salt);

    /// @notice Revert if someone tries to reinitialize an instance.
    error AlreadyInitialized();

    /// @notice Emit when a clone is created.
    event Cloned(address indexed clone);
}
