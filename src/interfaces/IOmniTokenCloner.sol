// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IOmniToken.sol";

/// @notice Deploy clones of OmniToken.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IOmniTokenCloner is IOmniToken {
    /// @notice Hold configuration data for deploying a clone.
    /// @dev properties are in alphabetical order to simplify converting json to abi-encoded bytes.
    struct Config {
        /// @notice the recipient of the minted tokens.
        address mintRecipient;
        /// @notice Array of [chain, amount] pairs specifying how many tokens to mint on each chain.
        uint256[][] mints;
        /// @notice Name of the token.
        string name;
        /// @notice Specify the gas limit for executing the _lzReceive callback function on the destination chain in a LayerZero OFT transfer.
        uint128 receiverGasLimit;
        /// @notice Symbol of the token.
        string symbol;
    }

    /// @notice Predict the address of a clone, which may or may not already exist.
    /// @param config The configuration for the clone.
    /// @return clone The predicted address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(config));
    function cloneAddress(Config memory config) external view returns (address clone, bytes32 salt);

    /// @notice Create a clone if it doesn't already exist.
    /// @param config The configuration for the clone.
    /// @return clone The address of the clone.
    /// @return salt The salt used to create the clone. salt = keccak256(abi.encode(kvs));
    function clone(Config memory config) external returns (address clone, bytes32 salt);

    /// @notice Revert if someone tries to reinitialize an instance.
    error AlreadyInitialized();

    /// @notice Revert if someone tries to initialize with an empty symbol.
    error SymbolEmpty();

    /// @notice Emit when a clone is created.
    event Cloned(address indexed mintRecipient, address indexed clone, string name, string symbol);
}
