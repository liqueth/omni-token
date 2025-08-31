// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IOmniRef.sol";
import "./interfaces/IOmniRefProto.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @title OmniRef
/// @notice Ensures the same contract address exists on every chain, with each instance
/// immutably referencing its chain’s designated target.
/// @dev Deployed deterministically with CREATE2, OmniRef binds immutably to the local
/// target for the current chain. This provides a trustless reference with no governance
/// or upgrade risk, eliminating the need for off-chain registries or per-chain config.
/// Contracts, SDKs, and UIs can hardcode one address and always resolve correctly.
/// Typical uses include cross-chain endpoints (oracles, messengers, executors), wallets,
/// bridges, and explorers that require a single uniform reference across chains.
/// @author Paul Reinholdtsen
contract OmniRef is IOmniRef, IOmniRefProto {
    address private _target;

    constructor() {
        // Prevent the implementation contract from being initialized.
        _target = address(this);
    }

    /// @dev Initialize the target address with the entry for the current chain.
    /// Can only be called once by the prototype during creation.
    /// @param target_ The target address for the current chain.
    function __OmniRef_init(address target_) public {
        if (_target != address(0)) revert AlreadyInitialized();
        _target = target_;
        emit Created(address(this), target_);
    }

    /// @inheritdoc IOmniRefProto
    function createPrediction(Entry[] memory entries)
        public
        view
        returns (address ref, bytes32 salt, address target_)
    {
        salt = keccak256(abi.encode(entries));
        ref = Clones.predictDeterministicAddress(address(this), salt, address(this));

        for (uint256 i; i < entries.length; ++i) {
            if (entries[i].chainId == block.chainid) {
                if (target_ != address(0)) revert DuplicateChainId();
                target_ = entries[i].target;
                if (target_ == address(0)) revert TargetIsZero();
            }
        }
        if (target_ == address(0)) revert UnsupportedChain();
    }

    /// @inheritdoc IOmniRefProto
    function create(Entry[] memory entries) public returns (address ref, bytes32 salt, address target_) {
        (ref, salt, target_) = createPrediction(entries);
        if (ref.code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            OmniRef(ref).__OmniRef_init(target_);
        }
    }

    /// @inheritdoc IOmniRef
    function target() external view returns (address) {
        return _target;
    }
}
