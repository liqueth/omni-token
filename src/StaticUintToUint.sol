// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IUintToUint.sol";
import "./interfaces/IUintToUintCloner.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @notice Map uint256 to uint256.
/// @dev Deployed by Nick's deterministic deployer at 0x4e59b44847b379578588920cA78FbF26c0B4956C,
/// StaticUintToUint has no governance or upgrade risk.
/// The implementation is also a factory, allowing anyone to easily deploy an instance.
/// @author Paul Reinholdtsen
contract StaticUintToUint is IUintToUint, IUintToUintCloner {
    /// @inheritdoc IUintToUint
    function keyCount() external view returns (uint256) {
        return keys.length;
    }

    /// @inheritdoc IUintToUint
    function keyAt(uint256 index) external view returns (uint256 key) {
        return keys[index];
    }

    /// @inheritdoc IUintToUint
    function valueOf(uint256 key) external view returns (uint256 value) {
        return values[key];
    }

    /// @inheritdoc IUintToUintCloner
    function cloneAddress(Entry[] memory entries) public view returns (address clone_, bytes32 salt) {
        salt = keccak256(abi.encode(entries));
        clone_ = Clones.predictDeterministicAddress(address(this), salt);
    }

    /// @inheritdoc IUintToUintCloner
    function clone(Entry[] memory entries) public returns (address clone_, bytes32 salt) {
        (clone_, salt) = cloneAddress(entries);
        if (clone_.code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            StaticUintToUint(clone_).__init(entries);
            return (clone_, salt);
        }
    }

    uint256[] private keys;
    mapping(uint256 => uint256) private values;
    bool private _initialized;

    /// @dev Prevent the implementation contract from being initialized.
    constructor() {
        _initialized = true;
    }

    /// @dev Only the cloner should call __init.
    /// @param entries The array of key value pairs sorted by key.
    function __init(Entry[] memory entries) public {
        if (_initialized) revert AlreadyInitialized();
        _initialized = true;
        for (uint256 i; i < entries.length; ++i) {
            keys.push(entries[i].key);
            values[entries[i].key] = entries[i].value;
        }
        emit Cloned(address(this));
    }
}
