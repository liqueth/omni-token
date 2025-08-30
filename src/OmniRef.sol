// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IOmniRef.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract OmniRef is IOmniRef {
    event Referenced(address indexed target);

    error AlreadyInitialized();

    struct Entry {
        uint256 chainId;
        address target;
    }

    /// @notice The chain‑specific address for this chain.
    address private _target;

    function initialize(Entry[] memory entries) public {
        if (_target != address(0)) revert AlreadyInitialized();

        for (uint256 i; i < entries.length; ++i) {
            if (entries[i].chainId == block.chainid) {
                _target = entries[i].target;
                emit Referenced(_target);
                return;
            }
        }
        revert UnsupportedChain();
    }

    function createPrediction(Entry[] memory entries) public view returns (address ref, bytes32 salt) {
        salt = keccak256(abi.encode(entries));
        ref = Clones.predictDeterministicAddress(address(this), salt, address(this));
    }

    function create(Entry[] memory entries) public returns (address ref, bytes32 salt) {
        (ref, salt) = createPrediction(entries);
        if (address(ref).code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            OmniRef(address(ref)).initialize(entries);
        }
    }

    function target() external view returns (address) {
        return _target;
    }
}
