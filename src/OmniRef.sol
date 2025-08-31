// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IOmniRef.sol";
import "./interfaces/IOmniRefProto.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @title OmniRef
/// @notice Ensures the same contract address exists on every chain, with each instance
/// immutably referencing its chain’s designated local.
/// @dev Deployed deterministically with CREATE2, OmniRef binds immutably to the local
/// local for the current chain. This provides a trustless reference with no governance
/// or upgrade risk, eliminating the need for off-chain registries or per-chain config.
/// Contracts, SDKs, and UIs can hardcode one address and always resolve correctly.
/// Typical uses include cross-chain endpoints (oracles, messengers, executors), wallets,
/// bridges, and explorers that require a single uniform reference across chains.
/// @author Paul Reinholdtsen
contract OmniRef is IOmniRef, IOmniRefProto {
    /// @inheritdoc IOmniRef
    function local() external view returns (address) {
        return _local;
    }

    /// @inheritdoc IOmniRefProto
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

    /// @inheritdoc IOmniRefProto
    function clone(Entry[] memory entries) public returns (address global, bytes32 salt, address local_) {
        (global, salt, local_) = locate(entries);
        if (global.code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            OmniRef(global).__OmniRef_init(local_);
        }
    }

    address private _local;

    constructor() {
        // Prevent the implementation contract from being initialized.
        _local = address(this);
    }

    /// @dev Initialize the local address with the entry for the current chain.
    /// Can only be called once by the prototype during cloning.
    /// @param local_ The local address for the current chain.
    function __OmniRef_init(address local_) public {
        if (_local != address(0)) revert AlreadyInitialized();
        _local = local_;
        emit Cloned(address(this), local_);
    }
}
