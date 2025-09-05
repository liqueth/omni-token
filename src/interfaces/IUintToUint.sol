// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Map uint256 to uint256.
/// @author Paul Reinholdtsen
interface IUintToUint {
    /// @notice Returns the total number of keys in the map.
    function keyCount() external view returns (uint256);

    /// @notice Returns the key stored at a given index.
    /// @dev Index must be less than {keyCount}.
    /// @param index The position in the key list.
    /// @return key The key at the specified index.
    function keyAt(uint256 index) external view returns (uint256 key);

    /// @notice Returns the value associated with a given key.
    /// @dev Reverts if the key does not exist.
    /// @param key The key to look up.
    /// @return value The value mapped to the given key.
    function valueOf(uint256 key) external view returns (uint256 value);
}
