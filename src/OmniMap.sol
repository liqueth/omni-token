// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IOmniMap.sol";
import "./interfaces/IOmniMapProto.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @notice Map a single predictable contract address to many unique chain local addresses.
/// @dev Deployed by the deterministic deployer at 0x4e59b44847b379578588920cA78FbF26c0B4956C,
/// OmniMap provides a trustless reference with no governance or upgrade risk.
/// Contracts, SDKs, and UIs can hardcode one address and always resolve correctly.
/// Typical uses include cross-chain endpoints (oracles, messengers, executors), wallets,
/// bridges, and explorers that require a single uniform reference across chains.
/// @dev The implementation contract is also a protofactory, allowing anyone to deploy new OmniMaps.
/// @author Paul Reinholdtsen
contract OmniMap is IOmniMap, IOmniMapProto {
    /// @inheritdoc IOmniMap
    function local() external view returns (address) {
        return _local;
    }

    /// @inheritdoc IOmniMapProto
    function predictAddress(Entry[] memory entries) public view returns (address global, bytes32 salt) {
        salt = keccak256(abi.encode(entries));
        global = Clones.predictDeterministicAddress(address(this), salt, address(this));
    }

    /// @inheritdoc IOmniMapProto
    function clone(Entry[] memory entries) public returns (address global, bytes32 salt) {
        (global, salt) = predictAddress(entries);
        if (global.code.length == 0) {
            for (uint256 i; i < entries.length; ++i) {
                if (entries[i].chainId == block.chainid) {
                    Clones.cloneDeterministic(address(this), salt);
                    OmniMap(global).__OmniMap_init(entries[i].local);
                    return (global, salt);
                }
            }
        }
    }

    address private _local;
    bool private _initialized;

    /// @dev Prevent the implementation contract from being initialized.
    constructor() {
        _initialized = true;
    }

    /// @dev Only let the protofactory set the local address after cloning.
    /// @param local_ The local address for the current chain.
    function __OmniMap_init(address local_) public {
        if (_initialized) revert AlreadyInitialized();
        _initialized = true;
        _local = local_;
        emit Cloned(address(this), local_);
    }
}
