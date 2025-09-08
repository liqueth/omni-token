// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IOmniAddress.sol";
import "./interfaces/IOmniAddressCloner.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @notice Map a single predictable contract address to many chain value addresses.
/// @dev Deployed by Nick's deterministic deployer at 0x4e59b44847b379578588920cA78FbF26c0B4956C,
/// OmniAddress provides a trustless reference with no governance or upgrade risk.
/// Contracts, SDKs, and UIs can hardcode one address and resolve everywhere.
/// Typical uses include cross-chain endpoints (oracles, messengers, executors), wallets,
/// bridges, and explorers that require a single uniform reference across chains.
/// @dev The implementation is also a factory, allowing anyone to easily deploy an OmniAddresss.
/// @author Paul Reinholdtsen
contract OmniAddress is IOmniAddress, IOmniAddressCloner {
    /// @inheritdoc IOmniAddress
    function value() external view returns (address) {
        return _value;
    }

    /// @inheritdoc IOmniAddressCloner
    function cloneAddress(KeyValue[] memory keyValues) public view returns (address clone_, bytes32 salt) {
        salt = keccak256(abi.encode(keyValues));
        clone_ = Clones.predictDeterministicAddress(address(this), salt);
    }

    /// @inheritdoc IOmniAddressCloner
    function clone(KeyValue[] memory keyValues) public returns (address clone_, bytes32 salt) {
        (clone_, salt) = cloneAddress(keyValues);
        if (clone_.code.length == 0) {
            address value_;
            for (uint256 i; i < keyValues.length; ++i) {
                if (keyValues[i].key == block.chainid) {
                    value_ = keyValues[i].value;
                    break;
                }
            }
            Clones.cloneDeterministic(address(this), salt);
            OmniAddress(clone_).__OmniAddress_init(value_);
        }
    }

    address private _value;
    bool private _initialized;

    /// @dev Prevent the implementation contract from being initialized.
    constructor() {
        _initialized = true;
    }

    /// @dev Only let the cloner set the value address after cloning.
    /// @param value_ The value address for the current chain.
    function __OmniAddress_init(address value_) public {
        if (_initialized) revert AlreadyInitialized();
        _initialized = true;
        _value = value_;
        emit Cloned(address(this), value_);
    }
}
