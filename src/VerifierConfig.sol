// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OmniConfig.sol";

/// @notice Customize per chain.
contract VerifierConfig is OmniConfig {
    struct Chain {
        uint256 chainId;
        address dvn;
    }

    struct Global {
        uint256 version;
        string id;
        Chain[] chains;
    }

    string internal _id;
    address public immutable dvn;

    constructor(Global memory global) {
        version = global.version;
        _id = global.id;
        uint256 n = global.chains.length;
        _chains = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            Chain memory r = global.chains[i];
            _chains[i] = r.chainId;
            if (r.chainId == block.chainid) {
                dvn = r.dvn;
            }
        }

        if (dvn == address(0)) {
            revert UnsupportedChain();
        }
    }

    function id() external view returns (string memory) {
        return _id;
    }
}
