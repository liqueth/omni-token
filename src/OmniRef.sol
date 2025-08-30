// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/IOmniRef.sol";

contract OmniRef is IOmniRef {
    struct Entry {
        uint256 chainId;
        address target;
    }

    /// @notice The chain‑specific address for this chain.
    address public immutable target;

    event Initialized(address indexed target);

    constructor(Entry[] memory entries) {
        for (uint256 i; i < entries.length; ++i) {
            if (entries[i].chainId == block.chainid) {
                target = entries[i].target;
                emit Initialized(target);
                return;
            }
        }
        revert UnsupportedChain();
    }
}
