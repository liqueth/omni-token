// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IAddressLookup.sol";
import "./interfaces/IAddressLookupProto.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @notice Immutably map a single predictable contract address to a chain specific address.
/// The same contract deployed to the same address on different chains can return
/// different values based on the chain ID.
/// @dev Deterministic deployment provides a trustless reference with no governance or upgrade risk.
/// Contracts, SDKs, and UIs can hardcode one address and resolve everywhere.
/// Typical uses include cross-chain endpoints (oracles, messengers, executors), wallets,
/// bridges, and explorers that require a single uniform reference across chains.
/// @dev The implementation is also a factory, allowing anyone to easily deploy an AddressLookups.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract AddressLookup is IAddressLookup, IAddressLookupProto {
    /// @inheritdoc IAddressLookup
    function value() external view returns (address) {
        return _value;
    }

    /// @inheritdoc IAddressLookupProto
    function cloneAddress(KeyValue[] memory keyValues) public view returns (address clone_, bytes32 salt) {
        salt = keccak256(abi.encode(keyValues));
        clone_ = Clones.predictDeterministicAddress(address(this), salt);
    }

    /// @inheritdoc IAddressLookupProto
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
            AddressLookup(clone_).__AddressLookup_init(value_);
        }
    }

    bool private _initialized;
    address private _value;

    /// @dev Prevent the implementation contract from being initialized.
    constructor() {
        _initialized = true;
    }

    /// @dev Only let the cloner set the value address after cloning.
    /// @param value_ The value address for the current chain.
    function __AddressLookup_init(address value_) public {
        if (_initialized) revert InitializedAlready();
        _initialized = true;
        _value = value_;
        emit Cloned(address(this), value_);
    }
}
