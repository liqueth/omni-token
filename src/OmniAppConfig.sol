// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OmniConfig.sol";

/// @notice Contain initialization parameters customized per chain.
/// @dev Immutable after construction. No setters. Uses a small Packed bucket per chain to co-locate sub-32B scalars.
contract OmniAppConfig is OmniConfig {
    error UnsupportedDestinationChain(uint256 chain);

    struct ChainConfig {
        address blockedMessageLib;
        uint256 chainId;
        uint32 eid;
        address endpoint;
        address executor;
        address receiveLib;
        address sendLib;
    }

    struct GlobalConfig {
        ChainConfig[] chainConfigs;
    }

    mapping(uint256 => uint32) private _chainToEndpoint;
    address public immutable blockedMessageLib;
    address public immutable endpoint;
    address public immutable executor;
    address public immutable receiveLib;
    address public immutable sendLib;

    constructor(GlobalConfig memory config) {
        uint256 n = config.chainConfigs.length;
        _chains = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            ChainConfig memory r = config.chainConfigs[i];
            _chains[i] = r.chainId;
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

    function chainToEndpoint(uint256 chain) internal view returns (uint32 eid) {
        eid = _chainToEndpoint[chain];
        if (eid == 0) {
            revert UnsupportedDestinationChain(chain);
        }
    }
}
