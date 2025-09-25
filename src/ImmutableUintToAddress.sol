// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IUintToAddressProto.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @notice Immutable map from uint256 to address with no governance or upgrade risk.
/// The implementation is also a factory, allowing anyone to easily deploy an instance.
/// Deterministic deployment ensures identical addresses across chains.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract ImmutableUintToAddress is IUintToAddressProto {
    /// @inheritdoc IUintToAddress
    function keyCount() external view returns (uint256) {
        return _keys.length;
    }

    /// @inheritdoc IUintToAddress
    function keyAt(uint256 index) external view returns (uint256 key) {
        return _keys[index];
    }

    /// @inheritdoc IUintToAddress
    function valueOf(uint256 key) external view returns (address value) {
        return _values[key];
    }

    /// @inheritdoc IUintToAddress
    function keys() external view returns (uint256[] memory) {
        return _keys;
    }

    /// @inheritdoc IUintToAddress
    function values() external view returns (address[] memory vals) {
        vals = new address[](_keys.length);
        for (uint256 i; i < _keys.length; ++i) {
            vals[i] = _values[_keys[i]];
        }
    }

    /// @inheritdoc IUintToAddress
    function keyValues() external view returns (KeyValue[] memory kvs) {
        kvs = new KeyValue[](_keys.length);
        for (uint256 i; i < _keys.length; ++i) {
            kvs[i] = KeyValue({key: _keys[i], value: _values[_keys[i]]});
        }
    }

    /// @inheritdoc IUintToAddressProto
    function cloneAddress(KeyValue[] memory kvs) public view returns (address clone_, bytes32 salt) {
        salt = keccak256(abi.encode(kvs));
        clone_ = Clones.predictDeterministicAddress(address(this), salt);
    }

    /// @inheritdoc IUintToAddressProto
    function clone(KeyValue[] memory kvs) public returns (address clone_, bytes32 salt) {
        (clone_, salt) = cloneAddress(kvs);
        if (clone_.code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            ImmutableUintToAddress(clone_).__init(kvs);
            return (clone_, salt);
        }
    }

    uint256[] private _keys;
    mapping(uint256 => address) private _values;
    bool private _initialized;

    /// @dev Prevent the implementation contract from being initialized.
    constructor() {
        _initialized = true;
    }

    /// @dev Only the cloner should call __init.
    /// @param kvs The array of key value pairs sorted by key.
    function __init(KeyValue[] memory kvs) public {
        if (_initialized) revert AlreadyInitialized();
        _initialized = true;
        for (uint256 i; i < kvs.length; ++i) {
            _keys.push(kvs[i].key);
            _values[kvs[i].key] = kvs[i].value;
        }
        emit Cloned(address(this));
    }
}
