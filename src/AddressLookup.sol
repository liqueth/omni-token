// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IAddressLookup} from "./interfaces/IAddressLookup.sol";
import {IAddressLookupProto} from "./interfaces/IAddressLookupProto.sol";
import {Assertions} from "./Assertions.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

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

    using Assertions for address;

    /// @inheritdoc IAddressLookupProto
    function cloneAddress(KeyValue[] memory keyValues) public view returns (address expected, bytes32 salt) {
        salt = keccak256(abi.encode(keyValues));
        expected = Clones.predictDeterministicAddress(address(this), salt);
    }

    /// @inheritdoc IAddressLookupProto
    function clone(KeyValue[] memory keyValues) public returns (address expected, bytes32 salt) {
        (expected, salt) = cloneAddress(keyValues);
        if (expected.code.length == 0) {
            address value_;
            for (uint256 i; i < keyValues.length; ++i) {
                if (keyValues[i].key == block.chainid) {
                    value_ = keyValues[i].value;
                    break;
                }
            }
            Clones.cloneDeterministic(address(this), salt).assertEqual(expected);
            AddressLookup(expected).__AddressLookup_init(value_);
        }
    }

    bool private _initialized;
    address private _value;

    /// @dev Prevent the implementation contract from being initialized.
    constructor() {
        _initialized = true;
    }

    /// @dev Only let the owner set the value address after cloning.
    /// @param value_ The value address for the current chain.
    function __AddressLookup_init(address value_) public {
        if (_initialized) revert InitializedAlready();
        _initialized = true;
        _value = value_;
        emit Cloned(address(this), value_);
    }
}
