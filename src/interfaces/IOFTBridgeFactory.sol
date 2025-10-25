// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IMessagingConfig} from "./IMessagingConfig.sol";

/// @notice Deploy implementations of OmniToken.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IOFTBridgeFactory {
    /// @notice Predict the address of a thing, which may or may not already exist.
    /// @param config The configuration for the thing.
    /// @return thing The predicted address of the thing.
    function createAddress(IMessagingConfig config) external view returns (address thing);

    /// @notice Create a thing if it doesn't already exist.
    /// @param config The configuration for the thing.
    /// @return thing The address of the newly or already created thing.
    function create(IMessagingConfig config) external returns (address thing);

    /// @notice Emit when a thing is created.
    event Created(address indexed thing);
}
