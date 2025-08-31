// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IOmniMap.sol";
import "./interfaces/IOmniMapProto.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @title OmniMap
/// @notice Ensures the same contract address exists on every chain, with each instance
/// immutably referencing its chain’s designated local.
/// @dev Deployed deterministically with CREATE2, OmniMap binds immutably to the local
/// local for the current chain. This provides a trustless reference with no governance
/// or upgrade risk, eliminating the need for off-chain registries or per-chain config.
/// Contracts, SDKs, and UIs can hardcode one address and always resolve correctly.
/// Typical uses include cross-chain endpoints (oracles, messengers, executors), wallets,
/// bridges, and explorers that require a single uniform reference across chains.
/// @author Paul Reinholdtsen
contract OmniMap is IOmniMap, IOmniMapProto {
    /// @inheritdoc IOmniMap
    function local() external view returns (address) {
        return _local;
    }

    /// @inheritdoc IOmniMapProto
    function locate(Entry[] memory entries) public view returns (address global, bytes32 salt, address local_) {
        salt = keccak256(abi.encode(entries));
        global = Clones.predictDeterministicAddress(address(this), salt, address(this));

        for (uint256 i; i < entries.length; ++i) {
            if (entries[i].chainId == block.chainid) {
                if (local_ != address(0)) revert DuplicateChainId();
                local_ = entries[i].local;
                if (local_ == address(0)) revert LocalIsZero();
            }
        }
        if (local_ == address(0)) revert UnsupportedChain();
    }

    /// @inheritdoc IOmniMapProto
    function clone(Entry[] memory entries) public returns (address global, bytes32 salt, address local_) {
        (global, salt, local_) = locate(entries);
        if (global.code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            OmniMap(global).__OmniMap_init(local_);
        }
    }

    address private _local;

    /// @dev Prevent the implementation contract from being initialized.
    constructor() {
        _local = address(this);
    }

    /// @dev Only let the protofactory set the local address after cloning.
    /// @param local_ The local address for the current chain.
    function __OmniMap_init(address local_) public {
        if (_local != address(0)) revert AlreadyInitialized();
        _local = local_;
        emit Cloned(address(this), local_);
    }
}
