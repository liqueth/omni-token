// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Map uint256 to address.
/// @author Paul Reinholdtsen
interface IUintToAddress {
    /// @notice Map a key to a value.
    struct KeyValue {
        uint256 key;
        address value;
    }

    /// @return total number of keys in the map.
    function keyCount() external view returns (uint256);

    /// @dev Index must be less than {keyCount}.
    /// @param index The position in the key list.
    /// @return key at the specified index.
    function keyAt(uint256 index) external view returns (uint256 key);

    /// @dev Reverts if the key does not exist.
    /// @param key The key to look up.
    /// @return value mapped to the given key.
    function valueOf(uint256 key) external view returns (address value);

    /// @return all keys in the map.
    function keys() external view returns (uint256[] memory);

    /// @return all values in the map.
    function values() external view returns (address[] memory);

    /// @return all key/value pairs in the map.
    function keyValues() external view returns (KeyValue[] memory);
}
