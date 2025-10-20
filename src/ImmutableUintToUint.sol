// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IUintToUintProto, IUintToUint} from "./interfaces/IUintToUintProto.sol";
import {Assertions} from "./Assertions.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

/// @notice Immutable map from uint256 to uint256 with no governance or upgrade risk.
/// The implementation is also a factory, allowing anyone to easily deploy an instance.
/// Deterministic deployment ensures identical addresses across chains.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract ImmutableUintToUint is IUintToUintProto {
    /// @inheritdoc IUintToUint
    function keyCount() external view returns (uint256) {
        return _keys.length;
    }

    /// @inheritdoc IUintToUint
    function keyAt(uint256 index) external view returns (uint256 key) {
        return _keys[index];
    }

    /// @inheritdoc IUintToUint
    function valueOf(uint256 key) external view returns (uint256 value) {
        return _values[key];
    }

    /// @inheritdoc IUintToUint
    function keys() external view returns (uint256[] memory) {
        return _keys;
    }

    /// @inheritdoc IUintToUint
    function values() external view returns (uint256[] memory vals) {
        vals = new uint256[](_keys.length);
        for (uint256 i; i < _keys.length; ++i) {
            vals[i] = _values[_keys[i]];
        }
    }

    /// @inheritdoc IUintToUint
    function keyValues() external view returns (KeyValue[] memory kvs) {
        kvs = new KeyValue[](_keys.length);
        for (uint256 i; i < _keys.length; ++i) {
            kvs[i] = KeyValue({key: _keys[i], value: _values[_keys[i]]});
        }
    }

    using Assertions for address;

    /// @inheritdoc IUintToUintProto
    function cloneAddress(KeyValue[] memory kvs) public view returns (address expected, bytes32 salt) {
        salt = keccak256(abi.encode(kvs));
        expected = Clones.predictDeterministicAddress(address(this), salt);
    }

    /// @inheritdoc IUintToUintProto
    function clone(KeyValue[] memory kvs) public returns (address expected, bytes32 salt) {
        (expected, salt) = cloneAddress(kvs);
        if (expected.code.length == 0) {
            Clones.cloneDeterministic(address(this), salt).assertEqual(expected);
            ImmutableUintToUint(expected).__init(kvs);
            return (expected, salt);
        }
    }

    uint256[] private _keys;
    mapping(uint256 => uint256) private _values;
    bool private _initialized;

    /// @dev Prevent the implementation contract from being initialized.
    constructor() {
        _initialized = true;
    }

    /// @dev Only the cloner should call __init.
    /// @param kvs The array of key value pairs sorted by key.
    function __init(KeyValue[] memory kvs) public {
        if (_initialized) revert InitializedAlready();
        _initialized = true;
        for (uint256 i; i < kvs.length; ++i) {
            _keys.push(kvs[i].key);
            _values[kvs[i].key] = kvs[i].value;
        }
        emit Cloned(address(this));
    }
}
