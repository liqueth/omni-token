// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OmniConfig.sol";

/// @notice Contain initialization parameters customized per chain.
/// @dev Immutable after construction. No setters. Uses a small Packed bucket per chain to co-locate sub-32B scalars.
contract EndpointConfig is OmniConfig {
    error UnsupportedDestinationChain(uint256 chain);

    struct Chain {
        address blockedMessageLib;
        uint256 chainId;
        uint32 eid;
        address endpoint;
        address executor;
        address receiveLib;
        address sendLib;
    }

    struct Global {
        Chain[] chains;
        uint256 version;
    }

    mapping(uint256 => uint32) public _chainToEndpoint;
    address public immutable blockedMessageLib;
    address public immutable endpoint;
    address public immutable executor;
    address public immutable receiveLib;
    address public immutable sendLib;

    constructor(Global memory global) {
        version = global.version;
        uint256 n = global.chains.length;
        _chains = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            Chain memory r = global.chains[i];
            _chains[i] = r.chainId;
            _chainToEndpoint[r.chainId] = r.eid;
            if (r.chainId == block.chainid) {
                blockedMessageLib = r.blockedMessageLib;
                endpoint = r.endpoint;
                executor = r.executor;
                sendLib = r.sendLib;
                receiveLib = r.receiveLib;
            }
        }

        if (endpoint == address(0)) {
            revert UnsupportedChain();
        }
    }

    function chainToEndpoint(uint256 chain) external view returns (uint32 eid) {
        eid = _chainToEndpoint[chain];
        if (eid == 0) {
            revert UnsupportedDestinationChain(chain);
        }
    }
}
