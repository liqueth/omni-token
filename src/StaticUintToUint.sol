// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IUintToUintCloner.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @notice Map uint256 to uint256.
/// @dev Deployed by Nick's deterministic deployer at 0x4e59b44847b379578588920cA78FbF26c0B4956C,
/// StaticUintToUint has no governance or upgrade risk.
/// The implementation is also a factory, allowing anyone to easily deploy an instance.
/// @author Paul Reinholdtsen
contract StaticUintToUint is IUintToUintCloner {
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

    /// @inheritdoc IUintToUintCloner
    function cloneAddress(KeyValue[] memory kvs) public view returns (address clone_, bytes32 salt) {
        salt = keccak256(abi.encode(kvs));
        clone_ = Clones.predictDeterministicAddress(address(this), salt);
    }

    /// @inheritdoc IUintToUintCloner
    function clone(KeyValue[] memory kvs) public returns (address clone_, bytes32 salt) {
        (clone_, salt) = cloneAddress(kvs);
        if (clone_.code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            StaticUintToUint(clone_).__init(kvs);
            return (clone_, salt);
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
        if (_initialized) revert AlreadyInitialized();
        _initialized = true;
        for (uint256 i; i < kvs.length; ++i) {
            _keys.push(kvs[i].key);
            _values[kvs[i].key] = kvs[i].value;
        }
        emit Cloned(address(this));
    }
}
