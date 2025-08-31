// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IOmniRef.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @notice OmniRef maps a uniform contract address across chains to a chain specific address.
/// @dev Deployed at the same address on every chain, OmniRef immutably binds to
/// the chain’s local target, providing a trustless reference with no governance
/// or upgrade risk. This removes off-chain registries and per-chain config,
/// letting contracts, SDKs, and UIs hardcode one address and always resolve locally.
/// Applications: cross-chain endpoints (oracles/messengers/executors), wallets/bridges
/// and explorers needing a single, immutable address that maps to the correct local contract.
/// @author Paul Reinholdtsen
contract OmniRef is IOmniRef {
    address private _target;

    constructor() {
        // Prevent the implementation contract from being initialized.
        _target = address(this);
    }

    /// @dev Initialize the target address with the entry for the current chain.
    /// Can only be called once by the prototype during creation.
    /// @param entries The array of chainId/target pairs to choose from.
    function __OmniRef_init(Entry[] memory entries) public {
        if (_target != address(0)) revert AlreadyInitialized();

        address t;

        for (uint256 i; i < entries.length; ++i) {
            if (entries[i].chainId == block.chainid) {
                if (t != address(0)) revert DuplicateChainId();
                t = entries[i].target;
                if (t == address(0)) revert TargetIsZero();
            }
        }
        if (t == address(0)) revert UnsupportedChain();
        _target = t;
        emit Referenced(_target);
    }

    /// @inheritdoc IOmniRef
    function createPrediction(Entry[] memory entries) public view returns (address ref, bytes32 salt) {
        salt = keccak256(abi.encode(entries));
        ref = Clones.predictDeterministicAddress(address(this), salt, address(this));
    }

    /// @inheritdoc IOmniRef
    function create(Entry[] memory entries) public returns (address ref, bytes32 salt) {
        (ref, salt) = createPrediction(entries);
        if (ref.code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            OmniRef(ref).__OmniRef_init(entries);
        }
    }

    /// @inheritdoc IOmniRef
    function target() external view returns (address) {
        return _target;
    }
}
